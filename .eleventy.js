const markdownit = {
  _lib: require("markdown-it"),
  anchor: require("markdown-it-anchor"),
  attrs: require("markdown-it-attrs"),
  container: require("markdown-it-container"),
  footnote: require("markdown-it-footnote"),
  toc: require("markdown-it-table-of-contents"),
};

module.exports = function(config) {
  config.ignores.add("README.md");

  config.addPassthroughCopy("src/.well-known");
  config.addPassthroughCopy("src/assets");

  const mdLib = markdownit._lib({
    html: true,
  }).use(markdownit.anchor.default)
    .use(markdownit.attrs)
    .use(markdownit.footnote)
    .use(markdownit.toc, { includeLevel: [2,3,4]})
    .use(markdownit.container, "callout")
  config.setLibrary("md", mdLib);

  return {
    dir: {
      input: "src",
    }
  };
};
