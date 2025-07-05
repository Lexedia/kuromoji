class IpadicFormatter {
  Map<String, dynamic> formatEntry(
      int wordId, int position, String type, List<String> features) {
    return {
      'word_id': wordId,
      'word_position': position,
      'word_type': type,
      'surface_form': features[0],
      'pos': features[1],
      'pos_detail_1': features[2],
      'pos_detail_2': features[3],
      'pos_detail_3': features[4],
      'conjugated_type': features[5],
      'conjugated_form': features[6],
      'basic_form': features[7],
      'reading': features[8],
      'pronunciation': features[9],
    };
  }

  Map<String, dynamic> formatUnknownEntry(int wordId, int position, String type,
      List<String> features, String surfaceForm) {
    return {
      'word_id': wordId,
      'word_position': position,
      'word_type': type,
      'surface_form': surfaceForm,
      'pos': features[1],
      'pos_detail_1': features[2],
      'pos_detail_2': features[3],
      'pos_detail_3': features[4],
      'conjugated_type': features[5],
      'conjugated_form': features[6],
      'basic_form': features[7],
      'reading': features.elementAtOrNull(8),
      'pronunciation': features.elementAtOrNull(9),
    };
  }
}
