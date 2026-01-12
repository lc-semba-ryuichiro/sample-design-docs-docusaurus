import * as fs from 'node:fs';
import * as path from 'node:path';

export default async function globalSetup() {
  if (process.env.COVERAGE) {
    const coverageDir = path.join(process.cwd(), 'coverage');
    if (fs.existsSync(coverageDir)) {
      fs.rmSync(coverageDir, {recursive: true});
    }
    fs.mkdirSync(coverageDir, {recursive: true});
  }
}
