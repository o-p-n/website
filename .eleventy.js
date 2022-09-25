const pluginTOC = require("eleventy-plugin-nesting-toc");

const markdownit = {
  _lib: require("markdown-it"),
  anchor: require("markdown-it-anchor"),
  attrs: require("markdown-it-attrs"),
  container: require("markdown-it-container"),
  footnote: require("markdown-it-footnote"),
};

module.exports = function(config) {
  config.ignores.add("README.md");

  config.addPassthroughCopy("src/.well-known");
  config.addPassthroughCopy("src/assets");

  config.addPlugin(pluginTOC);

  const mdLib = markdownit._lib({
    html: true,
  }).use(markdownit.anchor.default)
    .use(markdownit.attrs)
    .use(markdownit.container, "callout")
    .use(markdownit.footnote)
  config.setLibrary("md", mdLib);

  return {
    dir: {
      input: "src",
    }
  };
};
