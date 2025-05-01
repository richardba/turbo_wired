import resolve from "@rollup/plugin-node-resolve";
import { terser } from "rollup-plugin-terser";
import pkg from "./package.json";

export default [
  // Development-friendly build: readable and uncompressed
  {
    input: pkg.module,
    output: {
      file: pkg.main, // Output file defined in package.json
      format: "esm", // ES module format
      inlineDynamicImports: true, // Inline dynamic imports for simplicity
    },
    plugins: [
      resolve(), // Resolve node modules
      terser({
        mangle: false, // Keep variable names intact
        compress: false, // Disable compression for readability
        format: {
          beautify: true, // Beautify the output
          indent_level: 2, // Indentation level for clarity
        },
      }),
    ],
  },

  // Production-ready build: optimized and minified
  {
    input: pkg.module,
    output: {
      file: "app/assets/javascripts/turbo.min.js", // Minified output file
      format: "esm", // ES module format
      inlineDynamicImports: true, // Inline dynamic imports for simplicity
      sourcemap: true, // Include sourcemap for debugging
    },
    plugins: [
      resolve(), // Resolve node modules
      terser({
        mangle: true, // Shorten variable names for smaller size
        compress: true, // Enable compression for optimization
      }),
    ],
  },
];
