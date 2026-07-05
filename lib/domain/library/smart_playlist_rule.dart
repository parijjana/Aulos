import 'package:aulos/core/network/json_types.dart';

enum RuleField {
  title,
  artist,
  album,
  genre,
  year,
  rating,
  playCount,
  isFavorite,
  lastPlayed,
  durationSeconds,
}

enum RuleOperator {
  equals,
  notEquals,
  contains,
  greaterThan,
  lessThan,
  before,
  after,
  isTrue,
  isFalse,
}

class SmartPlaylistRule {
  final RuleField field;
  final RuleOperator operator;
  final String value; // String format for easy storage

  SmartPlaylistRule({
    required this.field,
    required this.operator,
    required this.value,
  });

  factory SmartPlaylistRule.fromJson(JsonMap json) {
    return SmartPlaylistRule(
      field: RuleField.values.firstWhere((e) => e.name == json['field']),
      operator: RuleOperator.values.firstWhere((e) => e.name == json['operator']),
      value: json['value'] as String,
    );
  }

  JsonMap toJson() {
    return {
      'field': field.name,
      'operator': operator.name,
      'value': value,
    };
  }
}

class SmartPlaylistConfig {
  final List<SmartPlaylistRule> rules;
  final bool matchAll; // true = AND, false = OR
  final int? limit;

  SmartPlaylistConfig({
    required this.rules,
    this.matchAll = true,
    this.limit,
  });

  factory SmartPlaylistConfig.fromJson(JsonMap json) {
    final rulesList = (json['rules'] as List? ?? [])
        .map((r) => SmartPlaylistRule.fromJson(r as JsonMap))
        .toList();
    return SmartPlaylistConfig(
      rules: rulesList,
      matchAll: json['matchAll'] as bool? ?? true,
      limit: json['limit'] as int?,
    );
  }

  JsonMap toJson() {
    return {
      'rules': rules.map((r) => r.toJson()).toList(),
      'matchAll': matchAll,
      if (limit != null) 'limit': limit,
    };
  }
}
