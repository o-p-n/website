module.exports = function(config) {
  config.ignores.add("README.md");

  config.addPassthroughCopy(".well-known");
  config.addPassthroughCopy("assets");
};
