import container from "npm:markdown-it-container@4.0.0";
import footnote from "npm:markdown-it-footnote@4.0.0";

const markdown = {
  plugins: [
    [container, "callout"],
    footnote,
  ],
};

export default markdown;
