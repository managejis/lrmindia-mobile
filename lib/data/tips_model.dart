class TipStep {
  final String title;
  final List<String> points;
  const TipStep(this.title, this.points);
}

class TipsContent {
  final String title, intro, flowHeading, generalHeading;
  final List<TipStep> steps;
  final List<String> general;
  const TipsContent({required this.title, required this.intro, required this.flowHeading, required this.generalHeading, required this.steps, required this.general});
}
