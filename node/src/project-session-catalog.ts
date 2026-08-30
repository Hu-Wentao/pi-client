export interface PiNodeProjectSessionRecord {
  readonly cwd: string;
  readonly modifiedAtMs: number;
}

export interface PiNodeProjectSessionCatalog {
  listAll(): Promise<readonly PiNodeProjectSessionRecord[]>;
}
