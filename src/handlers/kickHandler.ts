import chalk from 'chalk';

export enum KickReason {
    SERVER_FULL = 'SERVER_FULL',
    WHITELIST = 'WHITELIST',
    BANNED = 'BANNED',
    AUTHENTICATION = 'AUTHENTICATION',
    VERSION_MISMATCH = 'VERSION_MISMATCH',
    MAINTENANCE = 'MAINTENANCE',
    TIMEOUT = 'TIMEOUT',
    MODDED = 'MODDED',
    PROXY = 'PROXY',
    KICKED = 'KICKED',
    RATE_LIMIT = 'RATE_LIMIT',
    OTHER = 'OTHER',
}

export class KickReasonHandler {
    private static readonly reasonDescriptions: Map<KickReason, string> = new Map([
        [KickReason.SERVER_FULL, 'Server is at maximum capacity'],
        [KickReason.WHITELIST, 'Server is whitelisted'],
        [KickReason.BANNED, 'Banned from server'],
        [KickReason.AUTHENTICATION, 'Authentication error'],
        [KickReason.VERSION_MISMATCH, 'Minecraft version incompatible'],
        [KickReason.MAINTENANCE, 'Server under maintenance'],
        [KickReason.TIMEOUT, 'Connection timeout'],
        [KickReason.OTHER, 'Unmapped reason'],
        [KickReason.MODDED, 'Server is modded'],
        [KickReason.PROXY, 'Proxy Server'],
        [KickReason.RATE_LIMIT, 'Rate limiter, waiting to reconnect'],
        [KickReason.KICKED, 'Manually kicked'],
    ]);

    /**
     * Analyzes a raw kick reason string and returns a categorized reason
     */
    static categorizeKickReason(rawReason: string): KickReason {
        if (!rawReason) {
            return KickReason.OTHER;
        }

        if (typeof rawReason !== 'string') {
            rawReason = JSON.stringify(rawReason);
        }

        const cleanReason = rawReason.toLowerCase().trim();

        // Check for server full patterns
        if (this.matchesPatterns(cleanReason, [/server.*full/i])) {
            return KickReason.SERVER_FULL;
        }

        if (this.matchesPatterns(cleanReason, [/whitelist/, /discord/, /unverified/])) {
            return KickReason.WHITELIST;
        }

        if (this.matchesPatterns(cleanReason, [/banned/, /serverseeker/, /serverscanner/])) {
            return KickReason.BANNED;
        }

        if (this.matchesPatterns(cleanReason, [/invalid.*session/i])) {
            return KickReason.AUTHENTICATION;
        }

        if (
            this.matchesPatterns(cleanReason, [
                /version/i,
                /outdated.*client/i,
                /outdated.*server/i,
                /incompatible/i,
                /wrong.*version/i,
            ])
        ) {
            return KickReason.VERSION_MISMATCH;
        }

        if (this.matchesPatterns(cleanReason, [/maintenance/i, /server.*closed/i])) {
            return KickReason.MAINTENANCE;
        }

        if (this.matchesPatterns(cleanReason, [/timeout/i, /timed.*out/i])) {
            return KickReason.TIMEOUT;
        }

        if (
            this.matchesPatterns(cleanReason, [
                /neoforge/,
                /fabric loader/,
                /modloader/,
                /forge/,
                /missing.*mods/,
                /bettercombat/,
            ])
        ) {
            return KickReason.MODDED;
        }

        if (this.matchesPatterns(cleanReason, [/velocity/, /bungeeguard/, /bungeecord/])) {
            return KickReason.PROXY;
        }

        if (this.matchesPatterns(cleanReason, [/multiplayer\.disconnect\.kicked/])) {
            return KickReason.KICKED;
        }

        if (this.matchesPatterns(cleanReason, [/throttled/])) {
            return KickReason.RATE_LIMIT;
        }

        // Return OTHER for unknown reasons
        return KickReason.OTHER;
    }

    /**
     * Helper method to check if a string matches any of the given patterns
     */
    private static matchesPatterns(text: string, patterns: RegExp[]): boolean {
        return patterns.some(pattern => pattern.test(text));
    }

    /**
     * Formats a kick reason with both category and original message
     * For OTHER reasons, print the whole thing we can use it
     */
    static formatKickMessage(rawReason: string, serverInfo: { ip: string; port: number }): string {
        const category = this.categorizeKickReason(rawReason);
        const description = this.reasonDescriptions.get(category) || this.reasonDescriptions.get(KickReason.OTHER)!;

        if (category === KickReason.OTHER) {
            const reasonString = typeof rawReason === 'string' ? rawReason : JSON.stringify(rawReason);
            return chalk.red(
                `Kicked from ${serverInfo.ip}:${serverInfo.port} - ${description}: "${reasonString}" NEW/UNKNOWN PATTERN`
            );
        }
        return chalk.red(`Kicked from ${serverInfo.ip}:${serverInfo.port} - ${description}`);
    }

    //   /**
    //    * Determines if a kick reason indicates the bot should retry later
    //    */
    //   static shouldRetryLater(reason: KickReason): boolean {
    //     switch (reason) {
    //       case KickReason.SERVER_FULL:
    //       case KickReason.MAINTENANCE:
    //       case KickReason.TIMEOUT:
    //         return true;
    //       case KickReason.BANNED:
    //       case KickReason.WHITELIST:
    //       case KickReason.AUTHENTICATION:
    //       case KickReason.VERSION_MISMATCH:
    //         return false;
    //       case KickReason.OTHER:
    //         return false; // Don't retry unknown reasons
    //       default:
    //         return false;
    //     }
    //   }

    /**
     * Gets statistics about kick reasons (useful for debugging)
     */
    static getKickStatistics(): { reason: KickReason; description: string }[] {
        return Array.from(this.reasonDescriptions.entries()).map(([reason, description]) => ({
            reason,
            description,
        }));
    }
}
