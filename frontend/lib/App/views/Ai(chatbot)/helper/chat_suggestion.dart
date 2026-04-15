class ChatSuggestions {
  static List<String> getInitialSuggestions() {
    return [
      "How will my career grow this year?",
      "What does my birth chart say about love?",
      "When will I get financial stability?",
      "How is my marriage life looking?",
      "Which planet is affecting me most right now?",
    ];
  }

  static List<String> getSuggestionsFromQuestion(String question) {
    final q = question.toLowerCase();

    if (q.contains("marriage") ||
        q.contains("love") ||
        q.contains("relationship")) {
      return [
        "When will I get married?",
        "Will it be a love or arranged marriage?",
        "How will my married life be?",
        "Is my partner supportive?",
        "Any remedies for better relationship harmony?",
      ];
    }

    if (q.contains("career") || q.contains("job") || q.contains("work")) {
      return [
        "Will I get a promotion soon?",
        "Is business better than a job for me?",
        "Which field suits me most?",
        "Will I work abroad?",
        "How can I remove career obstacles?",
      ];
    }

    if (q.contains("money") || q.contains("finance") || q.contains("wealth")) {
      return [
        "When will my income increase?",
        "Will I become financially stable?",
        "Is property investment good for me?",
        "What causes financial delays in my chart?",
        "Any remedies for wealth growth?",
      ];
    }

    // Default fallback
    return [
      "Tell me more about my future",
      "What challenges are ahead for me?",
      "Which year is most important for me?",
      "What does my destiny say?",
      "Any spiritual advice for me?",
    ];
  }
}
