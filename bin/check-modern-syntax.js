const fs = require('fs');
const path = require('path');

const ROOT_DIR = process.argv[2] || '.';
const BAD_PATTERNS = [
  { regex: /\?\./, message: 'Optional chaining (?.)' },
  { regex: /\?\?/, message: 'Nullish coalescing (??)' },
  { regex: /\bawait\b/, message: 'Top-level await (only if used outside async)' },
  { regex: /\.at\s*\(/, message: 'Array.prototype.at or String.prototype.at' },
  { regex: /Object\.hasOwn\s*\(/, message: 'Object.hasOwn()' },
  { regex: /Promise\.allSettled\s*\(/, message: 'Promise.allSettled()' },
];

function scanFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');

  lines.forEach((line, idx) => {
    BAD_PATTERNS.forEach(({ regex, message }) => {
      if (regex.test(line)) {
        console.warn(`[WARN] ${filePath}:${idx + 1} → ${message}`);
        console.warn(`       ${line.trim()}`);
      }
    });
  });
}

function walk(dir) {
  fs.readdirSync(dir).forEach((file) => {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory() && file !== 'node_modules') {
      walk(fullPath);
    } else if (file.endsWith('.js') || file.endsWith('.ts')) {
      scanFile(fullPath);
    }
  });
}

console.log(`Scanning for incompatible syntax in '${ROOT_DIR}'...\n`);
walk(ROOT_DIR);
