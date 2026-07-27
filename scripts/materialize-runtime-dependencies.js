"use strict";

const fs = require("node:fs");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const packageIndex = path.join(root, "Packages", "_Index");
const dependenciesRoot = path.join(root, "src", "Dependencies");
const destination = path.join(dependenciesRoot, "_ReactPackages");
const expectedDestination = path.join(dependenciesRoot, "_ReactPackages");

if (path.resolve(destination) !== path.resolve(expectedDestination)) {
  throw new Error(`Refusing unexpected materialization target: ${destination}`);
}
if (!fs.statSync(packageIndex).isDirectory()) {
  throw new Error(`Run "wally install" first; package index is missing: ${packageIndex}`);
}

fs.rmSync(destination, { recursive: true, force: true });
fs.mkdirSync(destination, { recursive: true });

function copyRuntimeTree(source, target) {
  fs.cpSync(source, target, {
    recursive: true,
    filter: (entry) => {
      const relative = path.relative(source, entry);
      if (relative.split(path.sep).includes("__tests__")) {
        return false;
      }
      const stats = fs.statSync(entry);
      if (stats.isDirectory()) {
        return true;
      }
      const name = path.basename(entry);
      return !name.includes(".spec.") && (entry.endsWith(".lua") || entry.endsWith(".luau"));
    },
  });
}

let materialized = 0;
for (const packageKey of fs.readdirSync(packageIndex).sort()) {
  if (packageKey === "evaera_promise@4.0.0") {
    continue;
  }
  const packageRoot = path.join(packageIndex, packageKey);
  if (!fs.statSync(packageRoot).isDirectory()) {
    continue;
  }
  const targetRoot = path.join(destination, packageKey);
  fs.mkdirSync(targetRoot, { recursive: true });

  for (const entry of fs.readdirSync(packageRoot)) {
    const source = path.join(packageRoot, entry);
    if (fs.statSync(source).isFile() && (entry.endsWith(".lua") || entry.endsWith(".luau"))) {
      const target = path.join(targetRoot, entry);
      const contents = fs.readFileSync(source, "utf8");
      if (entry === "Promise.lua" && contents.includes("evaera_promise@4.0.0")) {
        fs.writeFileSync(target, "return require(script.Parent.Parent.Parent.Promise)\n");
      } else {
        fs.copyFileSync(source, target);
      }
    }
  }

  const packageDirectories = fs
    .readdirSync(packageRoot)
    .map((entry) => path.join(packageRoot, entry))
    .filter((entry) => fs.statSync(entry).isDirectory());
  if (packageDirectories.length !== 1) {
    throw new Error(`Expected one source package under ${packageRoot}, found ${packageDirectories.length}`);
  }
  const sourcePackage = packageDirectories[0];
  const sourceTree = fs.existsSync(path.join(sourcePackage, "src"))
    ? path.join(sourcePackage, "src")
    : sourcePackage;
  copyRuntimeTree(sourceTree, path.join(targetRoot, path.basename(sourcePackage)));
  materialized += 1;
}

console.log(
  `Materialized ${materialized} React runtime packages into ${path.relative(root, destination)}`,
);

const serverPackageIndex = path.join(root, "scripts", "vendor", "ServerPackages", "_Index");
const profileStorePackage = path.join(
  serverPackageIndex,
  "lm-loleris_profilestore@1.0.3",
  "profilestore",
);
const profileStoreSource = path.join(profileStorePackage, "ProfileStore.luau");
const profileStoreDestination = path.join(dependenciesRoot, "ProfileStore.luau");

if (!fs.existsSync(profileStoreSource) || !fs.statSync(profileStoreSource).isFile()) {
  throw new Error(`ProfileStore source is missing after Wally install: ${profileStoreSource}`);
}
fs.copyFileSync(profileStoreSource, profileStoreDestination);
console.log(`Materialized ProfileStore 1.0.3 into ${path.relative(root, profileStoreDestination)}`);
