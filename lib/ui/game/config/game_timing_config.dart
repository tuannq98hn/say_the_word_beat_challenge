import 'package:flutter/material.dart';

/// Game Timing Configuration
/// 
/// File này chứa tất cả các timing constants cho game để dễ dàng quản lý và điều chỉnh
/// mà không cần sửa code ở nhiều nơi.
/// 
/// Cách sử dụng:
/// - Import: `import '../config/game_timing_config.dart';`
/// - Sử dụng: `GameTimingConfig.countdownInterval`
/// 
/// Để thay đổi timing, chỉ cần sửa giá trị constants trong file này.
/// Tất cả các thay đổi sẽ tự động áp dụng cho toàn bộ game.
class GameTimingConfig {
  GameTimingConfig._();

  // ============================================================================
  // COUNTDOWN (3-2-1) TIMING
  // ============================================================================
  
  /// Thời gian giữa mỗi số trong countdown (3-2-1)
  /// Mặc định: 600ms
  /// Giảm giá trị này để countdown nhanh hơn, tăng để chậm hơn
  static const Duration countdownInterval = Duration(milliseconds: 600);
  
  /// Thời gian animation cho countdown number
  /// Mặc định: 600ms
  /// Điều chỉnh để thay đổi tốc độ fade in/out của số countdown
  static const Duration countdownAnimationDuration = Duration(milliseconds: 600);

  // ============================================================================
  // PREVIEW WORDS TIMING
  // ============================================================================
  
  /// Thời gian hiển thị preview words (danh sách từ sẽ xuất hiện) trước khi bắt đầu game
  /// Mặc định: 500ms
  /// Tăng giá trị này để người chơi có nhiều thời gian xem preview words
  static const Duration previewWordsDisplayDuration = Duration(milliseconds: 500);
  
  /// Delay trước khi bắt đầu countdown sau khi initialize game
  /// Mặc định: 0ms (không delay)
  /// Có thể tăng nếu cần delay trước khi bắt đầu countdown
  static const Duration preCountdownDelay = Duration(milliseconds: 0);

  // ============================================================================
  // MUSIC TIMING
  // ============================================================================
  
  /// Delay trước khi phát nhạc sau khi bắt đầu game
  /// Mặc định: 0ms (phát nhạc ngay lập tức)
  /// Tăng giá trị này để delay trước khi nhạc bắt đầu phát
  /// Ví dụ: Nếu muốn nhạc bắt đầu sau 500ms → set = Duration(milliseconds: 500)
  static const Duration musicStartDelay = Duration(milliseconds: 900);

  // ============================================================================
  // CARD ANIMATION TIMING
  // ============================================================================
  
  /// Thời gian animation khi card xuất hiện (slide in từ dưới lên)
  /// Mặc định: 50ms
  /// Tăng giá trị này để card xuất hiện chậm hơn, mượt hơn
  static const Duration cardAppearanceDuration = Duration(milliseconds: 150);
  
  /// Thời gian animation khi card thay đổi trạng thái (active/inactive border)
  /// Mặc định: 0ms (tức thời)
  /// Tăng giá trị này để border highlight mượt hơn khi chuyển đổi
  static const Duration cardBorderAnimationDuration = Duration(milliseconds: 150);
  
  /// Thời gian animation khi emoji/image scale khi active
  /// Mặc định: 75ms
  /// Tăng giá trị này để scale effect mượt hơn
  static const Duration cardScaleAnimationDuration = Duration(milliseconds: 175);

  // ============================================================================
  // FEEDBACK WORD TIMING
  // ============================================================================
  
  /// Thời gian hiển thị feedback word (GOOD!, PERFECT!, etc.) giữa các level
  /// Mặc định: 500ms
  /// Tăng giá trị này để feedback word hiển thị lâu hơn
  /// Lưu ý: Thời gian thực tế hiển thị phụ thuộc vào feedbackWordStartTick và feedbackWordEndTick
  static const Duration feedbackWordAnimationDuration = Duration(milliseconds: 500);

  // ============================================================================
  // LEVEL TRANSITION TIMING
  // ============================================================================
  
  /// Delay trước khi chuyển sang level tiếp theo sau khi feedback word ẩn
  /// Mặc định: 0ms (chuyển ngay lập tức)
  /// Tăng giá trị này để có delay giữa các level
  static const Duration levelTransitionDelay = Duration(milliseconds: 100);
  
  /// Delay trước khi hiển thị màn "Challenge Complete" sau khi level cuối kết thúc
  /// Mặc định: 300ms
  /// Tăng giá trị này để delay lâu hơn trước khi show complete screen
  static const Duration gameCompleteDelay = Duration(milliseconds: 300);
  
  /// Thời gian hiển thị text "next level" giữa các level
  /// Mặc định: 500ms (đã bao gồm trong feedback word timing)
  /// Có thể điều chỉnh riêng nếu cần

  // ============================================================================
  // BEAT INDICATOR TIMING
  // ============================================================================
  
  /// Thời gian animation cho beat indicator (4 chấm tròn ở top bar)
  /// Mặc định: 75ms
  /// Tăng giá trị này để beat indicator mượt hơn khi highlight
  static const Duration beatIndicatorAnimationDuration = Duration(milliseconds: 75);

  // ============================================================================
  // GAME FLOW TIMING
  // ============================================================================
  
  /// Delay nhỏ cho các thao tác UI (button press, state update, etc.)
  /// Mặc định: 100ms
  /// Sử dụng cho các delay nhỏ trong UI interactions
  static const Duration smallUIDelay = Duration(milliseconds: 100);
  
  /// Delay trung bình cho các thao tác cần thời gian xử lý
  /// Mặc định: 300ms
  /// Sử dụng cho các delay trung bình (như game complete transition)
  static const Duration mediumDelay = Duration(milliseconds: 300);
  
  /// Delay lớn cho các thao tác cần nhiều thời gian
  /// Mặc định: 500ms
  /// Sử dụng cho các delay lớn (như preview words)
  static const Duration largeDelay = Duration(milliseconds: 500);

  // ============================================================================
  // GAME TICK TIMING (Độc lập với audio)
  // ============================================================================
  
  /// Thời gian cho mỗi game tick (không phụ thuộc vào audio beats)
  /// Mặc định: 150ms
  /// Tính toán: Với BPM 138, 1 beat = 60/138 ≈ 435ms
  /// Nhưng để game chạy mượt hơn, dùng tick nhỏ hơn (150ms)
  /// Có thể điều chỉnh để game nhanh/chậm hơn
  static const Duration gameTickInterval = Duration(milliseconds: 310);
  
  /// Thời gian để hiển thị từng card một (mỗi card trong reveal phase)
  /// Mặc định: 375ms (để tổng 8 cards = 3 giây)
  /// Tăng giá trị này để cards xuất hiện chậm hơn
  static const Duration cardRevealInterval = Duration(milliseconds: 320);
  
  /// Thời gian để focus từng card một (mỗi card trong focus phase)
  /// Mặc định: 375ms (để tổng 8 cards = 3 giây)
  /// Tăng giá trị này để focus chậm hơn
  static const Duration cardFocusInterval = Duration(milliseconds: 375);

  /// Delay giữa khi hiển thị xong tất cả cards (reveal phase) và bắt đầu focus phase
  /// Mặc định: 50ms
  /// Tăng giá trị này để có khoảng nghỉ dài hơn giữa reveal và focus
  static const Duration revealToFocusDelay = Duration(milliseconds: 1300);

  // ============================================================================
  // ONE LEVEL TIMING SUMMARY (TỔNG THỜI GIAN CHO 1 LEVEL)
  // ============================================================================
  //
  // ═══════════════════════════════════════════════════════════════════════════
  // TỔNG QUAN: Mỗi level có 14 beats (tick 0-13)
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // Với BPM = 138 (mặc định):
  // - 1 beat = 60/138 ≈ 0.435 giây ≈ 435ms
  // - Tổng thời gian 1 level = 14 beats × 435ms = 6.09 giây
  //
  // Phân bổ thời gian trong 1 level:
  // - Tick 0-3 (4 beats): Reveal cards (2, 4, 6, 8 cards) ≈ 1.74 giây
  // - Tick 4-11 (8 beats): Highlight cards theo beat ≈ 3.48 giây
  // - Tick 12 (1 beat): Show feedback word ≈ 0.435 giây
  // - Tick 13 (1 beat): Clear feedback và chuyển level ≈ 0.435 giây
  //
  // ═══════════════════════════════════════════════════════════════════════════
  // ĐỂ ĐIỀU CHỈNH TỔNG THỜI GIAN 1 LEVEL:
  // ═══════════════════════════════════════════════════════════════════════════
  // 1. Thay đổi feedbackWordEndTick (tick cuối cùng của level)
  //    - Giảm để level ngắn hơn: feedbackWordEndTick = 12 → level = 13 beats
  //    - Tăng để level dài hơn: feedbackWordEndTick = 14 → level = 15 beats
  // 2. Thay đổi cardHighlightEndTick để điều chỉnh thời gian highlight
  //    - Giảm: cardHighlightEndTick = 11 → ít thời gian highlight hơn
  //    - Tăng: cardHighlightEndTick = 13 → nhiều thời gian highlight hơn
  // 3. Thay đổi BPM trong Difficulty enum để thay đổi tốc độ tổng thể
  //    - BPM cao hơn → level nhanh hơn
  //    - BPM thấp hơn → level chậm hơn
  //
  // ═══════════════════════════════════════════════════════════════════════════

  /// Số tick để hiển thị đủ 8 cards (4 tick đầu, mỗi tick 2 cards)
  /// Mặc định: 4
  /// Tick 0-3: Hiển thị cards (0: 2 cards, 1: 4 cards, 2: 6 cards, 3: 8 cards)
  /// Thời gian: 4 beats ≈ 1.74 giây (với BPM 138)
  static const int cardsRevealEndTick = 4;
  
  /// Số tick để bắt đầu highlight cards (active card)
  /// Mặc định: 4
  /// Từ tick 4 trở đi, bắt đầu highlight từng card theo beat
  static const int cardHighlightStartTick = 4;
  
  /// Số tick để kết thúc highlight cards
  /// Mặc định: 12
  /// Từ tick 4-11: Highlight cards (8 beats ≈ 3.48 giây với BPM 138)
  /// Tick 12: Clear active card và show feedback
  static const int cardHighlightEndTick = 12;
  
  /// Tick bắt đầu hiển thị feedback word
  /// Mặc định: 12
  /// Mỗi beat = ~435ms (với BPM 138), tick 12 = khoảng 5.22 giây sau khi bắt đầu level
  static const int feedbackWordStartTick = 12;
  
  /// Tick kết thúc hiển thị feedback word (cũng là tick cuối cùng của level)
  /// Mặc định: 13
  /// Feedback word sẽ hiển thị từ tick 12 đến tick 13 (1 beat ≈ 435ms)
  /// Đây là tick cuối cùng của level, sau đó sẽ chuyển sang level tiếp theo
  /// Tổng thời gian 1 level = 14 beats (tick 0-13) ≈ 6.09 giây (với BPM 138)
  static const int feedbackWordEndTick = 13;
  
  /// Số tick reset về 0 khi chuyển level
  /// Mặc định: 0
  /// Tick sẽ reset về 0 khi bắt đầu level mới
  static const int levelStartTick = 0;
  
  /// Số cards hiển thị ban đầu khi bắt đầu level
  /// Mặc định: 0
  /// Cards sẽ được reveal dần từ 0 đến 8
  static const int initialVisibleCardsCount = 0;
  
  /// Index của active card khi không có card nào active
  /// Mặc định: -1
  static const int noActiveCardIndex = -1;

  // ============================================================================
  // DECORATION ANIMATION TIMING
  // ============================================================================
  
  /// Thời gian animation cho các decoration icons (⭐, 🎵, ✨, etc.) trên background
  /// Mặc định: 2 giây
  /// Tăng giá trị này để decoration animation chậm hơn
  static const Duration decorationAnimationDuration = Duration(seconds: 2);

  // ============================================================================
  // ANIMATION CURVES
  // ============================================================================
  
  /// Curve cho card appearance animation
  /// Mặc định: Curves.easeOutCubic
  /// Có thể thay đổi: Curves.easeInOut, Curves.elasticOut, etc.
  static const Curve cardAppearanceCurve = Curves.easeOutCubic;
  
  /// Curve cho card scale animation
  /// Mặc định: Curves.easeInOut
  static const Curve cardScaleCurve = Curves.easeInOut;
}
