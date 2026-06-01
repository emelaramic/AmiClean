enum NacinPredaje {
  donosUCistionicu('DonosUCistionicu', 'Donijet ću u čistionicu'),
  preuzimanjeIDostava('PreuzimanjeIDostava', 'Preuzimanje i dostava');

  const NacinPredaje(this.apiVrijednost, this.naziv);

  final String apiVrijednost;
  final String naziv;
}
