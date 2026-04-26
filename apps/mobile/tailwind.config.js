/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{js,jsx,ts,tsx}",
    "./components/**/*.{js,jsx,ts,tsx}",
  ],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        primary: { DEFAULT: "#6B9E8A", dark: "#4E7A69" },
        secondary: { DEFAULT: "#C9A7D4" },
        warn: "#E8A95A",
        danger: "#E07A6E",
      },
    },
  },
  plugins: [],
};
