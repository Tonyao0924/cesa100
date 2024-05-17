class petRowData{
  String number, src;
  double bloodSugar, temperature;
  
  petRowData(this.number, this.bloodSugar, this.temperature, this.src);
}

List<petRowData> dataLens = [
  petRowData('97Q1234', 63.2, 42.1,'assets/home/cow.png'),
  petRowData('97Q1562', 230, 41.4,'assets/home/cat.png'),
  petRowData('97Q0134', 95, 37.1,'assets/home/cow.png'),
  petRowData('97Q9423', 90, 36.6,'assets/home/cow.png'),
  petRowData('97Q0886', 230, 37.8,'assets/home/dog.png'),
];