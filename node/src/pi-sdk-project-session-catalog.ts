import { resolve } from "node:path";

import { getAgentDir, SessionManager, SettingsManager } from "@earendil-works/pi-coding-agent";

import type {
  PiNodeProjectSessionCatalog,
  PiNodeProjectSessionRecord,
} from "./project-session-catalog.js";

export interface PublicPiSdkProjectSessionCatalogOptions {
  readonly agentDir: string;
  readonly defaultWorkingDirectory: string;
}

/** Uses only public Pi SDK session metadata and never constructs a runtime. */
export class PublicPiSdkProjectSessionCatalog implements PiNodeProjectSessionCatalog {
  readonly #agentDir: string;
  readonly #defaultWorkingDirectory: string;

  constructor(options: PublicPiSdkProjectSessionCatalogOptions) {
    this.#agentDir = options.agentDir;
    this.#defaultWorkingDirectory = options.defaultWorkingDirectory;
  }

  async listAll(): Promise<readonly PiNodeProjectSessionRecord[]> {
    const settingsManager = SettingsManager.create(this.#defaultWorkingDirectory, this.#agentDir, {
      projectTrusted: false,
    });
    const sessionDir = settingsManager.getSessionDir();
    const settingsErrors = settingsManager.drainErrors();
    if (settingsErrors.length > 0) {
      throw new Error("Pi settings could not be read for project discovery.");
    }
    if (sessionDir === undefined && resolve(this.#agentDir) !== resolve(getAgentDir())) {
      throw new Error("A non-default agent directory requires an explicit sessionDir setting.");
    }
    const sessions =
      sessionDir === undefined
        ? await SessionManager.listAll()
        : await SessionManager.listAll(sessionDir);
    return Object.freeze(
      sessions.map((session) =>
        Object.freeze({
          cwd: session.cwd,
          modifiedAtMs: session.modified.getTime(),
        }),
      ),
    );
  }
}
