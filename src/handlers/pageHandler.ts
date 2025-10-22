import * as fs from 'fs/promises';
import chalk from 'chalk';
import { ApiConfigFingerprint } from '../types';

interface PageData {
    offset: number;
    config?: ApiConfigFingerprint;
}

/**
 * Manages offset-based pagination for server scanning
 * Persists current offset to file for recovery after restarts
 * Resets offset when API config parameters change
 */
export class PageManager {
    private readonly pageFile = 'assets/page.json';
    private offset = 0;
    private lastConfig: ApiConfigFingerprint | null = null;

    constructor() {
        // no-op; call init() after construction to load file synchronously
    }

    async init(currentConfig?: ApiConfigFingerprint): Promise<void> {
        await this.loadOffsetFromFile(currentConfig);
    }

    private async loadOffsetFromFile(currentConfig?: ApiConfigFingerprint): Promise<void> {
        try {
            const data = await fs.readFile(this.pageFile, 'utf-8');
            const json: PageData = JSON.parse(data);
            
            // Check if config has changed
            if (currentConfig && json.config) {
                const configChanged = !this.configsMatch(json.config, currentConfig);
                if (configChanged) {
                    console.log(chalk.yellow('API config changed, resetting offset to 0'));
                    console.log('Previous config:', json.config);
                    console.log('Current config:', currentConfig);
                    this.offset = 0;
                    this.lastConfig = currentConfig;
                    await this.saveOffsetToFile();
                    return;
                }
            }
            
            if (typeof json.offset === 'number' && Number.isFinite(json.offset) && json.offset >= 0) {
                this.offset = json.offset;
                this.lastConfig = json.config || null;
                console.log(`Loaded offset ${this.offset} from file`);
            } else {
                console.log('Invalid page.json content, starting at offset 0');
                this.lastConfig = currentConfig || null;
                await this.saveOffsetToFile();
            }
        } catch (error) {
            if ((error as NodeJS.ErrnoException).code === 'ENOENT') {
                console.log('No existing page file found, starting at offset 0');
                this.lastConfig = currentConfig || null;
                await this.saveOffsetToFile();
            } else {
                console.error('Error loading page file:', error);
            }
        }
    }

    private configsMatch(config1: ApiConfigFingerprint, config2: ApiConfigFingerprint): boolean {
        return (
            config1.serverLimit === config2.serverLimit &&
            config1.playersOnlineRange === config2.playersOnlineRange &&
            config1.versionName === config2.versionName &&
            config1.whitelisted === config2.whitelisted
        );
    }

    private async saveOffsetToFile(): Promise<void> {
        try {
            const data: PageData = {
                offset: this.offset,
                config: this.lastConfig || undefined,
            };
            await fs.writeFile(this.pageFile, JSON.stringify(data, null, 2));
            // keep logs minimal
        } catch (error) {
            console.error('Error saving page file:', error);
        }
    }

    getCurrentOffset(): number {
        return this.offset;
    }

    async setCurrentOffset(offset: number): Promise<void> {
        if (!Number.isFinite(offset) || offset < 0) return;
        this.offset = Math.floor(offset);
        await this.saveOffsetToFile();
    }

    async incrementOffset(amount: number): Promise<number> {
        this.offset = this.offset + amount;
        await this.saveOffsetToFile();
        return this.offset;
    }

    async resetOffset(): Promise<void> {
        this.offset = 0;
        await this.saveOffsetToFile();
    }
}
