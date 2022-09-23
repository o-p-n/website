module.exports = function(config) {
  config.ignores.add("README.md");

  config.addPassthroughCopy("src/.well-known");
  config.addPassthroughCopy("src/assets");

  return {
    dir: {
      input: "src",
    }
  };
};
