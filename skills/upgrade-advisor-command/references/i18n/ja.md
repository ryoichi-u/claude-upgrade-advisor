# Upgrade Advisor — 日本語出力テンプレート

出力を日本語で生成する際は、以下のラベルとメッセージを使用すること。

## セクションヘッダー

- report_title: "アップグレードアドバイザー レポート"
- env_section: "環境情報"
- new_features_section: "利用可能な新機能"
- deprecations_section: "非推奨パターン警告"
- config_section: "設定改善提案"
- quick_wins_section: "Quick Wins（すぐにできる改善）"
- detailed_section: "詳細な推奨事項"
- summary_section: "サマリー"

## テーブルヘッダー

- col_feature: "機能"
- col_since: "導入バージョン"
- col_impact: "影響度"
- col_effort: "工数"
- col_action: "アクション"
- col_pattern: "パターン"
- col_file: "ファイル"
- col_deprecated_since: "非推奨化"
- col_migration: "移行方法"
- col_area: "対象"
- col_current: "現在の設定"
- col_recommended: "推奨設定"
- col_rationale: "理由"

## 影響度ラベル

- impact_high: "高"
- impact_medium: "中"
- impact_low: "低"

## 工数ラベル

- effort_low: "低（5分以内）"
- effort_medium: "中（5〜30分）"
- effort_high: "高（30分以上）"

## カテゴリラベル

- cat_adopt: "採用"
- cat_migrate: "移行"
- cat_optimize: "最適化"
- cat_alert: "注意"

## メッセージ

- msg_cache_stale: "リリースノートのキャッシュが{days}日前のものです。更新します..."
- msg_cache_fresh: "キャッシュ済みのリリースデータを使用します（{time_ago}に取得）。"
- msg_fetching: "GitHubから最新のリリースノートを取得中..."
- msg_no_updates: "セットアップは最新リリースに適合しています。新しい推奨事項はありません。"
- msg_found: "{releases}件のリリースから{count}件の改善提案が見つかりました。"
- msg_version_current: "Claude Code バージョン: {version}"
- msg_version_unknown: "Claude Codeのバージョンを特定できませんでした。"
- msg_releases_analyzed: "分析対象リリース: {from} ～ {to}（{count}件）"
- msg_files_scanned: "スキャン済みファイル数: {count}"
- msg_offer_apply: "これらの推奨事項を適用しますか？番号または 'all' で指定してください。"
- msg_complement: "トークンレベルの最適化には、claude-token-optimizer の `/token-audit` もお試しください。"
- msg_whatsnew_title: "Claude Code 最新情報"
- msg_whatsnew_empty: "最近のリリースが見つかりませんでした。"
- msg_deprecation_title: "非推奨パターンチェック レポート"
- msg_deprecation_clean: "セットアップに非推奨パターンは検出されませんでした。"
- msg_deprecation_found: "{count}件の非推奨パターンが見つかりました。"
- msg_deprecation_fix_offer: "`--fix` オプションで推奨される移行を適用できます。"
