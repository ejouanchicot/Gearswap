// GearSwap Atelier · icon_hd.js: the HD item icons made from the game's 32x32 ones, by the page itself
// (icon_cache.js reads an icon's bytes from atelier/icons/<id>.js, written by shared/utils/atelier/item_icons.lua,
// and shows the result instead of the .bmp). No library: it also runs under Node (scripts/atelier tests).
// The game's icons have an all-or-nothing alpha: hard stair edges, a dark fringe, uneven pixels at a Windows zoom of
// 125 / 150 %. Each one: the dark fringe dropped, Scale2x twice (EPX, a pixel-art upscaler that keeps edges sharp) to
// 128 px, the colour bled under the transparent part, the alpha softened (a Gaussian blur of 1.6 px), a Lanczos
// reduction to 64 px; the steps of Pillow the look was chosen with (notes/docs-perso/icones-hd-2026-10-30).
// The page shows them at 32 px (core.js itemImg).
//
// @author ejouanchicot
// @date   Created: 2026-10-30
(function (root) {
  'use strict';

  // A 32-bit BMP with its bit masks (BITMAPV4): {w, h, px: RGBA bytes top row first}, or null
  function readBmp(b) {
    if (!b || b.length < 54 || b[0] !== 0x42 || b[1] !== 0x4d) return null;
    const v = new DataView(b.buffer, b.byteOffset, b.byteLength), off = v.getUint32(10, true);
    const w = v.getInt32(18, true), hs = v.getInt32(22, true), h = Math.abs(hs);
    if (v.getUint16(28, true) !== 32 || w <= 0 || h <= 0 || off + w * h * 4 > b.length) return null;
    const bitfields = v.getUint32(30, true) === 3 && v.getUint32(14, true) >= 56;
    const masks = bitfields ? [54, 58, 62, 66].map(o => v.getUint32(o, true)) : [0xff0000, 0xff00, 0xff, 0xff000000];
    const shift = m => { let s = 0; if (!m) return -1; while (!((m >>> s) & 1)) s++; return s; };
    const sh = masks.map(shift), px = new Uint8Array(w * h * 4);
    for (let y = 0; y < h; y++) {
      const row = hs > 0 ? h - 1 - y : y;
      for (let x = 0; x < w; x++) {
        const p = v.getUint32(off + (row * w + x) * 4, true), o = (y * w + x) * 4;
        for (let c = 0; c < 4; c++) px[o + c] = sh[c] < 0 ? 255 : ((p & masks[c]) >>> sh[c]) & 255;
      }
    }
    return {w, h, px};
  }

  // EPX: each pixel becomes 4; a corner takes its neighbour's colour where two neighbours agree
  function scale2x(im) {
    const {w, h, px} = im, o = new Uint8Array(w * h * 16), W = w * 2;
    const at = (x, y) => (Math.min(h - 1, Math.max(0, y)) * w + Math.min(w - 1, Math.max(0, x))) * 4;
    const eq = (a, b) => px[a] === px[b] && px[a + 1] === px[b + 1] && px[a + 2] === px[b + 2] && px[a + 3] === px[b + 3];
    const put = (x, y, s) => { const d = (y * W + x) * 4; o[d] = px[s]; o[d + 1] = px[s + 1]; o[d + 2] = px[s + 2]; o[d + 3] = px[s + 3]; };
    for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) {
      const B = at(x, y - 1), D = at(x - 1, y), E = at(x, y), F = at(x + 1, y), H = at(x, y + 1);
      const ok = !eq(B, H) && !eq(D, F);
      put(2 * x, 2 * y, ok && eq(D, B) ? D : E); put(2 * x + 1, 2 * y, ok && eq(B, F) ? F : E);
      put(2 * x, 2 * y + 1, ok && eq(D, H) ? D : E); put(2 * x + 1, 2 * y + 1, ok && eq(H, F) ? F : E);
    }
    return {w: W, h: h * 2, px: o};
  }

  // the dark fringe: an opaque, very dark pixel touching the transparent outside; the transparent pixels made black
  function defringe(im) {
    const {w, h, px} = im, solid = (x, y) => x >= 0 && y >= 0 && x < w && y < h && px[(y * w + x) * 4 + 3] > 0;
    const drop = [];
    for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) {
      const o = (y * w + x) * 4;
      if (solid(x, y) && !(solid(x, y - 1) && solid(x, y + 1) && solid(x - 1, y) && solid(x + 1, y)) && px[o] + px[o + 1] + px[o + 2] < 75) drop.push(o);
    }
    for (const o of drop) px[o + 3] = 0;
    for (let o = 0; o < px.length; o += 4) if (!px[o + 3]) px[o] = px[o + 1] = px[o + 2] = 0;
  }

  // a plane (Float64Array w*h) through a one-way pass along x, then along y (edges repeated, as Pillow)
  function separable(src, w, h, pass) {
    const tmp = new Float64Array(w * h), out = new Float64Array(w * h), line = new Float64Array(Math.max(w, h)), res = new Float64Array(Math.max(w, h));
    for (let y = 0; y < h; y++) { for (let x = 0; x < w; x++) line[x] = src[y * w + x]; pass(line, w, res); for (let x = 0; x < w; x++) tmp[y * w + x] = res[x]; }
    for (let x = 0; x < w; x++) { for (let y = 0; y < h; y++) line[y] = tmp[y * w + x]; pass(line, h, res); for (let y = 0; y < h; y++) out[y * w + x] = res[y]; }
    return out;
  }
  // Pillow's MaxFilter(9) on one line: the largest value within 4 pixels
  const maxPass = (l, n, r) => { for (let i = 0; i < n; i++) { let m = 0; for (let k = Math.max(0, i - 4); k <= Math.min(n - 1, i + 4); k++) if (l[k] > m) m = l[k]; r[i] = m; } };
  // Pillow's GaussianBlur: three box blurs of a fractional radius (ImagingGaussianBlur, extended box blur)
  function boxPass(radius) {
    const whole = Math.floor(radius), frac = radius - whole, wgt = 1 / (2 * radius + 1);
    return (l, n, r) => {
      const at = i => l[Math.min(n - 1, Math.max(0, i))];
      for (let i = 0; i < n; i++) {
        let s = at(i - whole - 1) * frac + at(i + whole + 1) * frac;
        for (let k = -whole; k <= whole; k++) s += at(i + k);
        r[i] = s * wgt;
      }
    };
  }
  function gaussian(plane, w, h, radius) {
    const sigma2 = radius * radius / 3, L = Math.sqrt(12 * sigma2 + 1), l = Math.floor((L - 1) / 2);
    const a = (2 * l + 1) * (l * (l + 1) - 3 * sigma2) / (6 * (sigma2 - (l + 1) * (l + 1)));
    const pass = boxPass(l + a);
    let p = plane;
    for (let k = 0; k < 3; k++) p = separable(p, w, h, pass);
    return p;
  }
  // Lanczos (support 3) reduction of one line from n to n / 2, as Pillow's resize (its filter widened by the scale)
  const sinc = x => x === 0 ? 1 : Math.sin(Math.PI * x) / (Math.PI * x);
  const lanczos = x => Math.abs(x) < 3 ? sinc(x) * sinc(x / 3) : 0;
  // each output's first source pixel and its weights (summing to 1), worked out once a length
  const HALF = {};
  function halfCoeffs(n) {
    if (HALF[n]) return HALF[n];
    const list = [];
    for (let i = 0; i < n / 2; i++) {
      const c = (i + 0.5) * 2, lo = Math.max(0, Math.floor(c - 6 + 0.5)), hi = Math.min(n, Math.floor(c + 6 + 0.5));
      const wk = []; for (let k = lo; k < hi; k++) wk.push(lanczos((k - c + 0.5) / 2));
      const sum = wk.reduce((s, x) => s + x, 0);
      list.push({lo, wk: Float64Array.from(wk, x => sum ? x / sum : 0)});
    }
    return (HALF[n] = list);
  }
  function halfPass(l, n, r) {
    const cs = halfCoeffs(n);
    for (let i = 0; i < cs.length; i++) { const {lo, wk} = cs[i]; let s = 0; for (let k = 0; k < wk.length; k++) s += l[lo + k] * wk[k]; r[i] = s; }
  }
  function half(planes, w, h) {
    // the lines are made n long, the pass writes n / 2: kept from each plane's corner
    return planes.map(p => { const full = separable(p, w, h, (l, n, r) => { halfPass(l, n, r); for (let i = n / 2; i < n; i++) r[i] = 0; });
      const o = new Float64Array(w * h / 4); for (let y = 0; y < h / 2; y++) for (let x = 0; x < w / 2; x++) o[y * w / 2 + x] = full[y * w + x]; return o; });
  }

  // The HD icon of a game's icon: {w: 64, h: 64, px: RGBA bytes}, or null for a broken file
  function hdPixels(bmp) {
    let im = readBmp(bmp);
    if (!im) return null;
    defringe(im);
    im = scale2x(scale2x(im));
    const {w, h, px} = im, n = w * h, plane = c => { const p = new Float64Array(n); for (let i = 0; i < n; i++) p[i] = px[i * 4 + c]; return p; };
    const alpha = plane(3), rgb = [0, 1, 2].map(plane), grown = rgb.map(p => separable(p, w, h, maxPass));
    // the colour under the transparent part: the nearest opaque colour around, so no black creeps in when reduced
    for (let c = 0; c < 3; c++) for (let i = 0; i < n; i++) { const a = alpha[i] / 255; rgb[c][i] = Math.round(rgb[c][i] * a + grown[c][i] * (1 - a)); }
    const soft = gaussian(alpha, w, h, 1.6).map(Math.round);
    // reduced with the colour weighted by the alpha (Pillow's RGBa), then set back
    const pre = rgb.map(p => p.map((v, i) => v * soft[i] / 255)), [r, g, b, a] = half(pre.concat([soft]), w, h);
    const out = new Uint8Array(w * h);   // (w / 2) * (h / 2) * 4
    const clamp = v => Math.max(0, Math.min(255, Math.round(v)));
    for (let i = 0; i < a.length; i++) {
      const al = clamp(a[i]), k = al ? 255 / al : 0;
      out[i * 4] = clamp(r[i] * k); out[i * 4 + 1] = clamp(g[i] * k); out[i * 4 + 2] = clamp(b[i] * k); out[i * 4 + 3] = al;
    }
    return {w: w / 2, h: h / 2, px: out};
  }

  const api = {readBmp, hdPixels};
  if (typeof module === 'object' && module.exports) module.exports = api;
  else root.IconHD = api;
})(typeof window !== 'undefined' ? window : this);
