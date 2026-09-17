import { mkdir, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';

import openapiTS from 'openapi-typescript';
import swagger2openapi from 'swagger2openapi';

const swaggerUrl = 'http://192.168.0.50:8080/swagger/doc.json';
const outputPath = resolve('src/api/generated/openapi.ts');

const response = await fetch(swaggerUrl);
if (!response.ok) {
  throw new Error(`Download Swagger failed: HTTP ${response.status}.`);
}

const swagger = await response.json();
const { openapi } = await swagger2openapi.convertObj(swagger, { patch: true });
const output = await openapiTS(openapi, { alphabetize: true });

await mkdir(dirname(outputPath), { recursive: true });
await writeFile(outputPath, output, 'utf8');
console.log(`Generated ${outputPath} from ${swaggerUrl}`);
