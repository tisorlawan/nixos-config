# Tree-sitter grammars

Prebuilt grammar shared libraries for the web language modes
(typescript-ts-mode / tsx-ts-mode / js-ts-mode), compiled from source
because no grammar packages are available via nix on this machine.

## Files

| Library | Language symbol | Source repo |
|---|---|---|
| libtree-sitter-javascript.so | javascript | tree-sitter/tree-sitter-javascript |
| libtree-sitter-typescript.so | typescript | tree-sitter/tree-sitter-typescript |
| libtree-sitter-tsx.so | tsx | tree-sitter/tree-sitter-typescript (tsx/src) |
| libtree-sitter-jsdoc.so | jsdoc | tree-sitter/tree-sitter-jsdoc |
| libtree-sitter-js.so | js | tree-sitter/tree-sitter-javascript (renamed symbol) |
| libtree-sitter-ts.so | ts | tree-sitter/tree-sitter-typescript (renamed symbol) |

The `js` and `ts` libraries use cc -D renames because the upstream repos
export `tree_sitter_javascript` / `tree_sitter_typescript`, while some
tooling looks up `tree_sitter_js` / `tree_sitter_ts`.

## Rebuild

    git clone --depth 1 https://github.com/tree-sitter/tree-sitter-javascript
    git clone --depth 1 https://github.com/tree-sitter/tree-sitter-typescript
    git clone --depth 1 https://github.com/tree-sitter/tree-sitter-jsdoc

    G=~/.rice/emacs/tree-sitter
    cc -O2 -fPIC -Dtree_sitter_javascript=tree_sitter_js \
      -I tree-sitter-javascript/src -I tree-sitter-javascript/src/tree_sitter \
      -shared tree-sitter-javascript/src/parser.c tree-sitter-javascript/src/scanner.c \
      -o $G/libtree-sitter-js.so
    cc -O2 -fPIC -Dtree_sitter_typescript=tree_sitter_ts \
      -I tree-sitter-typescript/typescript/src -I tree-sitter-typescript/typescript/src/tree_sitter \
      -I tree-sitter-typescript/common \
      -shared tree-sitter-typescript/typescript/src/parser.c tree-sitter-typescript/typescript/src/scanner.c \
      -o $G/libtree-sitter-ts.so
    cc -O2 -fPIC \
      -I tree-sitter-typescript/tsx/src -I tree-sitter-typescript/tsx/src/tree_sitter \
      -I tree-sitter-typescript/common \
      -shared tree-sitter-typescript/tsx/src/parser.c tree-sitter-typescript/tsx/src/scanner.c \
      -o $G/libtree-sitter-tsx.so
    cc -O2 -fPIC \
      -I tree-sitter-jsdoc/src -I tree-sitter-jsdoc/src/tree_sitter \
      -shared tree-sitter-jsdoc/src/parser.c tree-sitter-jsdoc/src/scanner.c \
      -o $G/libtree-sitter-jsdoc.so

The `javascript` / `typescript` named libraries (no symbol rename) are
also built the same way without the -D flags; both naming schemes are
kept so any tooling that expects either name works.

The load path is registered in init.el:

    (add-to-list 'treesit-extra-load-path (locate-user-emacs-file "tree-sitter"))

The .so files are gitignored (binary build artifacts); rebuild them with
the commands above if the tree-sitter/ directory is empty.
