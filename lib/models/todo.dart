class ToDo {
	ToDo(this.id, this.texte);
	int id;
	String texte;

	Map<String, dynamic> toMap() {

		var map = Map<String, dynamic>();
		if (id != null) {
			map['id'] = id;
		}
		map['texte'] = texte;
		return map;
	}

	ToDo.fromMapObject(Map<String, dynamic> map) {
		this.id = map['id'];
		this.texte = map['texte'];
	}
}