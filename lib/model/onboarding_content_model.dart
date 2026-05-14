class OnboardingContent {
  String image;
  String title;
  String metin;

  OnboardingContent(
      {required this.image, required this.title, required this.metin});
}

List<OnboardingContent> contents = [
  OnboardingContent(
      title: 'Türkiyeyi Yerel Rehberle Keşfedin!',
      image: "assets/illustrations/onboarding1.png",
      metin:
          "Heyecan verici seyahatlere hazır olun! Yerel rehberlerimizle unutulmaz bir deneyim yaşayın."),
  OnboardingContent(
      title: 'Sizin İçin Özel Seyahat Planı',
      image: "assets/illustrations/onboarding2.png",
      metin:
          "Yerel rehberlerimizle hayallerinizdeki seyahat planını oluşturun, şehrin ruhunu keşfedin."),
  OnboardingContent(
      title: 'Gizli Kalmış Hazinelerden Haberdar Olun!',
      image: "assets/illustrations/onboarding3.png",
      metin:
          "Turistlerin gözden kaçırdığı eşsiz deneyimler ve saklı güzellikler sizi bekliyor."),
  OnboardingContent(
      title: 'Seyahat Tutkunu Olun, Puan Kazanın!',
      image: "assets/illustrations/onboarding4.png",
      metin:
          "Kendi şehrinize gelen gezginlere rehberlik edin, sinema, konser ve tiyatro bileti kazanın."),
];
