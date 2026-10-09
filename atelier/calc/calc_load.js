// Atelier calculation engine: builds CALC from the parts the other files registered.
// Load this file after every other atelier/calc/*.js file (plain scripts, no modules: the page
// is opened from disk). The parts only define tables and functions, so their order is free.
//
// @file    atelier/calc/calc_load.js
// @author  ejouanchicot
(function () {
    var CALC = globalThis.CALC = {};
    (globalThis.CALC_PARTS || []).forEach(function (part) { part(CALC); });
}());
