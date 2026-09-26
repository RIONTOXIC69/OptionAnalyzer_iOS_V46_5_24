import Foundation

enum AnalyzerIndex: String, CaseIterable, Identifiable {
    case nifty50 = "NIFTY 50"
    case bankNifty = "BANK NIFTY"
    case sensex = "SENSEX"

    var id: String { rawValue }
}

struct StatusResponse: Decodable {
    let appVersion: String?
    let generatedAtIST: String?
    let index: String?
    let expiry: String?
    let interday: Interday?
    let finalDecision: FinalDecision?
    let execution: ExecutionState?

    enum CodingKeys: String, CodingKey {
        case appVersion = "app_version"
        case generatedAtIST = "generated_at_ist"
        case index, expiry, interday
        case finalDecision = "final_decision"
        case execution
    }
}

struct Interday: Decodable {
    let direction: String?
    let setupDirection: String?
    let context: String?
    let contextDetail: String?
    let confirmation: String?
    let confirmationReady: Bool?
    let confirmedDirection: String?
    let action: String?
    let stage8: String?
    let stage9: String?
    let finalDecision: String?
    let bullSupport: Int?
    let bearSupport: Int?
    let mtfStatus: String?
    let entry: Double?
    let stopLoss: Double?
    let target2R: Double?

    enum CodingKeys: String, CodingKey {
        case direction
        case setupDirection = "setup_direction"
        case context
        case contextDetail = "context_detail"
        case confirmation
        case confirmationReady = "confirmation_ready"
        case confirmedDirection = "confirmed_direction"
        case action
        case stage8, stage9
        case finalDecision = "final_decision"
        case bullSupport = "bull_support"
        case bearSupport = "bear_support"
        case mtfStatus = "mtf_status"
        case entry
        case stopLoss = "stop_loss"
        case target2R = "target_2r"
    }
}

struct FinalDecision: Decodable {
    let decision: String?
    let bias: String?
    let quality: String?
    let reasons: [String]?
    let blockers: [String]?
}

struct ExecutionResponse: Decodable {
    let generatedAtIST: String?
    let index: String?
    let mtf: MTF?
    let execution: ExecutionState?
    let finalDecision: FinalDecision?

    enum CodingKeys: String, CodingKey {
        case generatedAtIST = "generated_at_ist"
        case index, mtf, execution
        case finalDecision = "final_decision"
    }
}

struct ExecutionState: Decodable {
    let direction: String?
    let mtfDirection: String?
    let setupDirection: String?
    let entry: Double?
    let trigger: Double?
    let stop: Double?
    let target1: Double?
    let target2: Double?
    let rr: Double?
    let target2R: Double?
    let targetStructural: Double?
    let entryStatus: String?
    let exitStatus: String?
    let detail: [String]?
    let candle: String?
    let setupStatus: String?
    let triggerDirection: String?
    let triggerStatus: String?
    let alignmentStatus: String?
    let confirmationStatus: String?
    let confirmationLevel: Double?
    let confirmationCandle: String?
    let triggerCandle: String?
    let executionPhase: String?
    let stage8Timestamp: String?
    let mtfAlignedAt: String?
    let confirmationTimestamp: String?
    let triggerTimestamp: String?

    enum CodingKeys: String, CodingKey {
        case direction
        case mtfDirection = "mtf_direction"
        case setupDirection = "setup_direction"
        case entry, trigger, stop
        case target1, target2, rr
        case target2R = "target_2r"
        case targetStructural = "target_structural"
        case entryStatus = "entry_status"
        case exitStatus = "exit_status"
        case detail, candle
        case setupStatus = "setup_status"
        case triggerDirection = "trigger_direction"
        case triggerStatus = "trigger_status"
        case alignmentStatus = "alignment_status"
        case confirmationStatus = "confirmation_status"
        case confirmationLevel = "confirmation_level"
        case confirmationCandle = "confirmation_candle"
        case triggerCandle = "trigger_candle"
        case executionPhase = "execution_phase"
        case stage8Timestamp = "stage8_timestamp"
        case mtfAlignedAt = "mtf_aligned_at"
        case confirmationTimestamp = "confirmation_timestamp"
        case triggerTimestamp = "trigger_timestamp"
    }
}

struct MTF: Decodable {
    let weekly: MTFTimeframe?
    let daily: MTFTimeframe?
    let fourHour: MTFTimeframe?
    let oneHour: MTFTimeframe?
    let tide: String?
    let wave: String?
    let alignment: String?

    enum CodingKeys: String, CodingKey {
        case weekly, daily
        case fourHour = "4h"
        case oneHour = "1h"
        case tide, wave, alignment
    }
}

struct MTFTimeframe: Decodable {
    let direction: String?
    let status: String?
    let close: Double?
    let fast: Double?
    let slow: Double?
    let detail: String?
}

struct StagesResponse: Decodable {
    let generatedAtIST: String?
    let index: String?
    let stages: StageContainer?
    let finalDecision: FinalDecision?

    enum CodingKeys: String, CodingKey {
        case generatedAtIST = "generated_at_ist"
        case index, stages
        case finalDecision = "final_decision"
    }
}

struct StageContainer: Decodable {
    let optionDirection: Stage1?
    let oiPriceAction: Stage2?
    let supportResistance: Stage3?
    let marketStructure: Stage4?
    let orderBlock: Stage5?
    let chartPattern: Stage6?
    let elliottWave: Stage7?
    let confirmationCandle: Stage8?
    let fibonacci: Stage9?

    enum CodingKeys: String, CodingKey {
        case optionDirection = "1_option_direction"
        case oiPriceAction = "2_oi_price_action"
        case supportResistance = "3_support_resistance"
        case marketStructure = "4_market_structure"
        case orderBlock = "5_order_block"
        case chartPattern = "6_chart_pattern"
        case elliottWave = "7_elliott_wave"
        case confirmationCandle = "8_confirmation_candle"
        case fibonacci = "9_fibonacci"
    }
}

struct Stage1: Decodable {
    let direction: String?
    let structure: String?
    let spot: Double?
    let support: Double?
    let resistance: Double?
    let confirmation: String?
    let evidence: [String]?
}

struct Stage2: Decodable {
    let available: Bool?
    let call: String?
    let put: String?
    let bias: String?
    let detail: String?
    let strength: String?
    let decision: String?
}

struct Stage3: Decodable {
    let available: Bool?
    let decision: String?
    let strength: String?
    let detail: String?
    let support: Double?
    let resistance: Double?
    let spot: Double?
}

struct Stage4: Decodable {
    let status: String?
    let trend: String?
    let bos: String?
    let choch: String?
    let swingHigh: Double?
    let swingLow: Double?
    let lastClose: Double?
    let lastCandle: String?
    let structure: String?
    let decision: String?
    let detail: String?

    enum CodingKeys: String, CodingKey {
        case status, trend, bos, choch
        case swingHigh = "swing_high"
        case swingLow = "swing_low"
        case lastClose = "last_close"
        case lastCandle = "last_candle"
        case structure, decision, detail
    }
}

struct Stage5: Decodable {
    let status: String?
    let bias: String?
    let type: String?
    let high: Double?
    let low: Double?
    let timestamp: String?
    let distance: Double?
    let location: String?
    let quality: String?
    let detail: String?
}

struct Stage6: Decodable {
    let status: String?
    let pattern: String?
    let bias: String?
    let confidence: String?
    let detail: String?
}

struct Stage7: Decodable {
    let status: String?
    let wave: String?
    let bias: String?
    let confidence: String?
    let detail: String?
    let invalidLevel: Double?
    let currentPosition: String?

    enum CodingKeys: String, CodingKey {
        case status, wave, bias, confidence, detail
        case invalidLevel = "invalid_level"
        case currentPosition = "current_position"
    }
}

struct Stage8: Decodable {
    let status: String?
    let signal: String?
    let candle: String?
    let close: Double?
    let level: Double?
    let quality: String?
    let detail: String?
    let timestamp: String?
}

struct Stage9: Decodable {
    let status: String?
    let signal: String?
    let bias: String?
    let quality: String?
    let swingLow: Double?
    let swingHigh: Double?
    let fib236: Double?
    let fib382: Double?
    let fib50: Double?
    let fib618: Double?
    let fib786: Double?
    let goldenZoneLow: Double?
    let goldenZoneHigh: Double?
    let detail: String?
    let timestamp: String?
    let retraceTouched: Bool?
    let reclaim: Bool?

    enum CodingKeys: String, CodingKey {
        case status, signal, bias, quality
        case swingLow = "swing_low"
        case swingHigh = "swing_high"
        case fib236 = "fib_23_6"
        case fib382 = "fib_38_2"
        case fib50 = "fib_50"
        case fib618 = "fib_61_8"
        case fib786 = "fib_78_6"
        case goldenZoneLow = "golden_zone_low"
        case goldenZoneHigh = "golden_zone_high"
        case detail, timestamp
        case retraceTouched = "retrace_touched"
        case reclaim
    }
}
