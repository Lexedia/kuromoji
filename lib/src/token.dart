base class UnknownToken<T extends String?> {
  /// Unique identifier for the dictionary entry or token.
  final int wordId;

  /// 1-based position of the token as it appears in the sentence.
  final int wordPosition;

  /// The exact text of the token as it appears in the sentence.
  final String surfaceForm;

  /// Coarse part-of-speech tag.
  final String pos;

  /// Three-part POS detail record, use this to preserve all POS detail strings exactly as provided.
  /// Some or all field(s) can be `*` if this is not available.
  final (String, String, String) posDetails;

  /// Conjugation class/type (e.g., "五段・カ行イ音便").
  /// `*` if not applicable.
  final String conjugatedType;

  /// Conjugation form (e.g., "基本形").
  /// `*` if not applicable.
  final String conjugatedForm;

  /// Lemma or dictionnary form of the token.
  /// `*` if not available.
  final String basicForm;

  /// Kana reading of the token.
  final T reading;

  /// Phonetic pronunciation of the token.
  final T pronunciation;

  const UnknownToken({
    required this.wordId,
    required this.wordPosition,
    required this.surfaceForm,
    required this.pos,
    required this.posDetails,
    required this.conjugatedForm,
    required this.conjugatedType,
    required this.basicForm,
    required this.reading,
    required this.pronunciation,
  });

  static UnknownToken<String?> from(
          int wordId, int position, String type, List<String> features, String? surfaceForm) =>
      type == 'KNOWN'
          ? UnknownToken<String?>(
              wordId: wordId,
              wordPosition: position,
              surfaceForm: features[0],
              pos: features[1],
              posDetails: (features[2], features[3], features[4]),
              conjugatedType: features[5],
              conjugatedForm: features[6],
              basicForm: features[7],
              reading: 8 > features.length ? null : features[8],
              pronunciation: 9 > features.length ? null : features[9],
            )
          : Token(
              wordId: wordId,
              wordPosition: position,
              surfaceForm: surfaceForm!,
              pos: features[1],
              posDetails: (features[2], features[3], features[4]),
              conjugatedType: features[5],
              conjugatedForm: features[6],
              basicForm: features[7],
              reading: features[8],
              pronunciation: features[9],
            );

  Map<String, Object?> toJson() => {
        'word_id': wordId,
        'word_position': wordPosition,
        'word_type': this is Token ? 'KNOWN' : 'UNKNOWN',
        'surface_form': surfaceForm,
        'pos': pos,
        'pos_detail_1': posDetails.$1,
        'pos_detail_2': posDetails.$2,
        'pos_detail_3': posDetails.$3,
        'conjugated_type': conjugatedType,
        'conjugated_form': conjugatedForm,
        'basic_form': basicForm,
        'reading': reading,
        'pronunciation': pronunciation,
      };
}

final class Token extends UnknownToken<String> {
  const Token({
    required super.reading,
    required super.pronunciation,
    required super.basicForm,
    required super.conjugatedForm,
    required super.conjugatedType,
    required super.pos,
    required super.posDetails,
    required super.surfaceForm,
    required super.wordId,
    required super.wordPosition,
  });
}
