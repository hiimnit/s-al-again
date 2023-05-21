/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      fontFamily: {
        monaco: ["Menlo", "Monaco", '"Courier New"', "monospace"],
        bc: [
          "Segoe UI",
          "Segoe WP",
          "Segoe",
          "device-segoe",
          "Tahoma",
          "Helvetica",
          "Arial",
          "sans-serif",
        ],
      },
      fontSize: {
        "bc-small": ["14px", "normal"],
      },
      colors: {
        bc: {
          100: "#d9f0f2",
        },
      },
    },
  },
  plugins: [],
};
