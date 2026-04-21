class ArabicLetter {
  final String letter;
  final String soundPath;
  final String name;

  ArabicLetter({
    required this.letter,
    required this.soundPath,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {'letter': letter, 'soundPath': soundPath, 'name': name};
  }

  factory ArabicLetter.fromJson(Map<String, dynamic> json) {
    return ArabicLetter(
      letter: json['letter'],
      soundPath: json['soundPath'],
      name: json['name'],
    );
  }
}

final List<ArabicLetter> arabicLetters = [
  ArabicLetter(
    letter: 'أ',
    name: 'Alif',
    soundPath: 'assets/audio/arabic_letters/alef.mp3',
  ),
  ArabicLetter(
    letter: 'ب',
    name: 'Ba',
    soundPath: 'assets/audio/arabic_letters/baa.mp3',
  ),
  ArabicLetter(
    letter: 'ت',
    name: 'Ta',
    soundPath: 'assets/audio/arabic_letters/taa.mp3',
  ),
  ArabicLetter(
    letter: 'ث',
    name: 'Tha',
    soundPath: 'assets/audio/arabic_letters/thaa.mp3',
  ),
  ArabicLetter(
    letter: 'ج',
    name: 'Jeem',
    soundPath: 'assets/audio/arabic_letters/jeem.mp3',
  ),
  ArabicLetter(
    letter: 'ح',
    name: 'Ha',
    soundPath: 'assets/audio/arabic_letters/haa.mp3',
  ),
  ArabicLetter(
    letter: 'خ',
    name: 'Kha',
    soundPath: 'assets/audio/arabic_letters/khaa.mp3',
  ),
  ArabicLetter(
    letter: 'د',
    name: 'Dal',
    soundPath: 'assets/audio/arabic_letters/dal.mp3',
  ),
  ArabicLetter(
    letter: 'ذ',
    name: 'Dhal',
    soundPath: 'assets/audio/arabic_letters/dhal.mp3',
  ),
  ArabicLetter(
    letter: 'ر',
    name: 'Ra',
    soundPath: 'assets/audio/arabic_letters/raa.mp3',
  ),
  ArabicLetter(
    letter: 'ز',
    name: 'Zay',
    soundPath: 'assets/audio/arabic_letters/zay.mp3',
  ),
  ArabicLetter(
    letter: 'س',
    name: 'Seen',
    soundPath: 'assets/audio/arabic_letters/seen.mp3',
  ),
  ArabicLetter(
    letter: 'ش',
    name: 'Sheen',
    soundPath: 'assets/audio/arabic_letters/sheen.mp3',
  ),
  ArabicLetter(
    letter: 'ص',
    name: 'Sad',
    soundPath: 'assets/audio/arabic_letters/sad.mp3',
  ),
  ArabicLetter(
    letter: 'ض',
    name: 'Dad',
    soundPath: 'assets/audio/arabic_letters/dad.mp3',
  ),
  ArabicLetter(
    letter: 'ط',
    name: 'Ta',
    soundPath: 'assets/audio/arabic_letters/taa2.mp3',
  ),
  ArabicLetter(
    letter: 'ظ',
    name: 'Za',
    soundPath: 'assets/audio/arabic_letters/zaa.mp3',
  ),
  ArabicLetter(
    letter: 'ع',
    name: 'Ain',
    soundPath: 'assets/audio/arabic_letters/ain.mp3',
  ),
  ArabicLetter(
    letter: 'غ',
    name: 'Ghain',
    soundPath: 'assets/audio/arabic_letters/ghain.mp3',
  ),
  ArabicLetter(
    letter: 'ف',
    name: 'Fa',
    soundPath: 'assets/audio/arabic_letters/fa.mp3',
  ),
  ArabicLetter(
    letter: 'ق',
    name: 'Qaf',
    soundPath: 'assets/audio/arabic_letters/qaf.mp3',
  ),
  ArabicLetter(
    letter: 'ك',
    name: 'Kaf',
    soundPath: 'assets/audio/arabic_letters/kaf.mp3',
  ),
  ArabicLetter(
    letter: 'ل',
    name: 'Lam',
    soundPath: 'assets/audio/arabic_letters/lam.mp3',
  ),
  ArabicLetter(
    letter: 'م',
    name: 'Meem',
    soundPath: 'assets/audio/arabic_letters/meem.mp3',
  ),
  ArabicLetter(
    letter: 'ن',
    name: 'Noon',
    soundPath: 'assets/audio/arabic_letters/noon.mp3',
  ),
  ArabicLetter(
    letter: 'ه',
    name: 'Ha',
    soundPath: 'assets/audio/arabic_letters/haa2.mp3',
  ),
  ArabicLetter(
    letter: 'و',
    name: 'Waw',
    soundPath: 'assets/audio/arabic_letters/waw.mp3',
  ),
  ArabicLetter(
    letter: 'ي',
    name: 'Ya',
    soundPath: 'assets/audio/arabic_letters/yaa.mp3',
  ),
];
