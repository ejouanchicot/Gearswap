// GearSwap Atelier · a menu that always shows the page's value. Svelte puts `selected` on an <option> as the default
// choice; once the player (or a script) has picked in the menu, the browser keeps its own choice and a value changed
// elsewhere (another set, a reset) may not show. This action sets the menu's choice from the page's at every redraw.
// `sel`: the value chosen, the values for a multiple menu; null or undefined leaves the menu as it is.
//
// @file    atelier/src/components/selsync.ts
// @author  ejouanchicot

type Sel = string | number | Array<string | number> | null | undefined;

/** use:selSync={value} on a <select> */
export function selSync(node: HTMLSelectElement, sel: Sel) {
  const apply = (v: Sel) => {
    if (v == null) return;
    const want = Array.isArray(v) ? v.map(String) : [String(v)];
    for (const o of node.options) o.selected = want.includes(o.value);
  };
  apply(sel);
  return {update: apply};
}
