/// Steps in the client job post wizard (7 total).
enum JobPostWizardStep {
  category(1, 'Select service'),
  subcategory(2, 'Service type'),
  title(3, 'Job title'),
  description(4, 'Description'),
  location(5, 'Location'),
  urgency(6, 'Budget & schedule'),
  summary(7, 'Review & post');

  const JobPostWizardStep(this.stepNumber, this.headline);

  final int stepNumber;
  final String headline;

  static const int totalSteps = 7;

  double get progress => stepNumber / totalSteps;

  String get stepLabel => 'STEP $stepNumber OF $totalSteps';

  int get percentComplete => (progress * 100).round();

  JobPostWizardStep? get next {
    final int index = indexOf(this);
    if (index < JobPostWizardStep.values.length - 1) {
      return JobPostWizardStep.values[index + 1];
    }
    return null;
  }

  static int indexOf(JobPostWizardStep step) =>
      JobPostWizardStep.values.indexOf(step);
}
