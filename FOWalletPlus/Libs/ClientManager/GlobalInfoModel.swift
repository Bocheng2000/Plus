//
//  GlobalInfoModel.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/21.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

class GlobalInfoModel: Codable {
    var max_block_net_usage: Int32!
    var target_block_net_usage_pct: Int32!
    var max_transaction_net_usage: Int32!
    var base_per_transaction_net_usage: Int32!
    var net_usage_leeway: Int32!
    var context_free_discount_net_usage_num: Int32!
    var context_free_discount_net_usage_den: Int32!
    var max_block_cpu_usage: Int32!
    var target_block_cpu_usage_pct: Int32!
    var max_transaction_cpu_usage: Int32!
    var min_transaction_cpu_usage: Int32!
    var max_transaction_lifetime: Int32!
    var deferred_trx_expiration_window: Int32!
    var max_transaction_delay: Int32!
    var max_inline_action_size: Int32!
    var max_inline_action_depth: Int32!
    var max_authority_depth: Int32!
    var max_ram_size: String!
    var total_ram_bytes_reserved: String!
    var total_ram_stake: String!
    var last_producer_schedule_update: String!
    var last_pervote_bucket_fill: String!
    var pervote_bucket: Int32!
    var perblock_bucket: Int32!
    var total_unpaid_blocks: Int32!
    var total_activated_stake: String!
    var thresh_activated_stake_time: String!
    var last_producer_schedule_size: Int32!
    var total_producer_vote_weight: String!
    var last_name_close: String!
    
    enum CodingKeys : String, CodingKey {
        case max_block_net_usage = "maxBlockNetUsage"
        case target_block_net_usage_pct = "targetBlockNetUsagePct"
        case max_transaction_net_usage = "maxTransactionNetUsage"
        case base_per_transaction_net_usage = "basePerTransactionNetUsage"
        case net_usage_leeway = "netUsageLeeway"
        case context_free_discount_net_usage_num = "contextFreeDiscountNetUsageNum"
        case context_free_discount_net_usage_den = "contextFreeDiscountNetUsageDen"
        case max_block_cpu_usage = "maxBlockCpuUsage"
        case target_block_cpu_usage_pct = "targetBlockCpuUsagePct"
        case max_transaction_cpu_usage = "maxTransactionCpuUsage"
        case min_transaction_cpu_usage = "minTransactionCpuUsage"
        case max_transaction_lifetime = "maxTransactionLifetime"
        case deferred_trx_expiration_window = "deferredTrxExpirationWindow"
        case max_transaction_delay = "maxTransactionDelay"
        case max_inline_action_size = "maxInlineActionSize"
        case max_inline_action_depth = "maxInlineActionDepth"
        case max_authority_depth = "maxAuthorityDepth"
        case max_ram_size = "maxRamSize"
        case total_ram_bytes_reserved = "totalRamBytesReserved"
        case total_ram_stake = "totalRamStake"
        case last_producer_schedule_update = "lastProducerScheduleUpdate"
        case last_pervote_bucket_fill = "lastPervoteBucketFill"
        case pervote_bucket = "pervoteBucket"
        case perblock_bucket = "perblockBucket"
        case total_unpaid_blocks = "totalUnpaidBlocks"
        case total_activated_stake = "totalActivatedStake"
        case thresh_activated_stake_time = "threshActivatedStakeTime"
        case last_producer_schedule_size = "lastProducerScheduleSize"
        case total_producer_vote_weight = "totalProducerVoteWeight"
        case last_name_close = "lastNameClose"
    }
}
