# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Pour.Repo.insert!(%Pour.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

region_data = %{
  "Africa" => %{
    "Algeria" => [
      "Algiers",
      "Béjaïa",
      "Chlef Province",
      "Mascara",
      "Médéa",
      "Tlemcen",
      "Zaccar"
    ],
    "Cape Verde" => ["Chã das Caldeiras"],
    "Morocco" => ["Atlas Mountains", "Benslimane", "Meknès"],
    "South Africa" => [
      "Breede River Valley",
      "Constantia",
      "Durbanville",
      "Elgin",
      "Elim",
      "Franschhoek",
      "Little Karoo",
      "Orange River Valley",
      "Paarl",
      "Robertson",
      "Stellenbosch",
      "Swartland",
      "Tulbagh"
    ],
    "Tunisia" => ["Arianah", "Nabul", "Sousse"]
  },
  "Argentina" => %{
    "Buenos Aires Province" => ["Médanos"],
    "Catamarca Province" => [],
    "La Rioja Province" => [],
    "Mendoza Province" => [],
    "Neuquén Province" => [],
    "Río Negro Province" => [],
    "Salta Province" => [],
    "San Juan Province" => []
  },
  "Bolivia" => %{
    "Tarija Department" => []
  },
  "Brazil" => %{
    "Bahia" => [
      "Curaçá",
      "Irecê",
      "Juazeiro"
    ],
    "Mato Grosso" => [
      "Nova Mutum"
    ],
    "Minas Gerais" => [
      "Andradas",
      "Caldas",
      "Pirapora",
      "Santa Rita de Caldas"
    ],
    "Paraná" => [
      "Bandeirantes",
      "Marialva",
      "Maringá",
      "Rosário do Avaí"
    ],
    "Pernambuco" => [
      "Casa Nova",
      "Petrolina",
      "Santa Maria da Boa Vista"
    ],
    "Rio Grande do Sul" => [
      "Bento Gonçalves",
      "Caxias do Sul",
      "Cotiporã",
      "Farroupilha",
      "Flores da Cunha",
      "Garibaldi",
      "Pinto Bandeira"
    ],
    "Santa Catarina" => [
      "Pinheiro Preto",
      "São Joaquim",
      "Tangará"
    ],
    "São Paulo" => [
      "Jundiaí",
      "São Roque"
    ]
  },
  "Chile" => %{
    "Aconcagua" => [
      "Aconcagua Valley",
      "Casablanca Valley"
    ],
    "Atacama" => [
      "Copiapó Valley",
      "Huasco Valley"
    ],
    "Central Valley" => [
      "Cachapoal Valley",
      "Maipo Valley",
      "Mataquito Valley",
      "Maule Valley"
    ],
    "Coquimbo" => [
      "Choapa Valley",
      "Elqui Valley",
      "Limarí"
    ],
    "Pica" => [
      "Bío-Bío Valley",
      "Itata Valley",
      "Malleco Valley",
      "Bueno Valley",
      "Ranco Lake"
    ],
    "Southern Chile" => [
      "Bío-Bío Valley",
      "Itata Valley",
      "Malleco Valley",
      "Bueno Valley",
      "Ranco Lake"
    ]
  },
  "France" => %{
    "Alsace" => [],
    "Bordeaux" => [
      "Barsac",
      "Entre-Deux-Mers",
      "Fronsac",
      "Graves",
      "Haut-Médoc",
      "Margaux",
      "Médoc",
      "Pauillac",
      "Pessac-Léognan",
      "Pomerol",
      "Saint-Émilion",
      "Saint-Estèphe",
      "Saint-Julien",
      "Sauternes"
    ],
    "Burgundy" => [
      "Beaujolais",
      "Bugey",
      "Chablis",
      "Côte Chalonnaise",
      "Côte d'Or",
      "Côte de Beaune",
      "Côte de Nuits",
      "Pouilly-Fuissé"
    ],
    "Champagne" => [],
    "Corsica" => [
      "Ajaccio",
      "Cap Course",
      "Patrimonio",
      "Vin de Corse"
    ],
    "Jura" => [],
    "Languedoc-Roussillon" => [
      "Banyuls",
      "Blanquette de Limoux",
      "Cabardès",
      "Collioure",
      "Corbières",
      "Côtes du Roussillon",
      "Fitou",
      "Maury",
      "Minervois",
      "Rivesaltes"
    ],
    "Loire Valley" => [
      "Anjou – Saumur",
      "Cognac",
      "Muscadet",
      "Pouilly-Fumé",
      "Sancerre"
    ],
    "Touraine" => [],
    "Lorraine" => [],
    "Madiran" => [],
    "Provence" => [],
    "Rhône" => [
      "Beaumes-de-Venise",
      "Château-Grillet",
      "Châteauneuf-du-Pape",
      "Condrieu",
      "Cornas",
      "Côte du Rhône-Villages, Rhône wine",
      "Côte-Rôtie",
      "Côtes du Rhône",
      "Crozes-Hermitage",
      "Gigondas",
      "Hermitage",
      "St. Joseph",
      "Saint-Péray",
      "Vacqueyras"
    ],
    "Savoy" => []
  },
  "Italy" => %{
    "Apulia" => [
      "Bianco di Locorotondo e Martina Franca",
      "Primitivo di Manduria"
    ],
    "Calabria" => [
      "Bivongi",
      "Cirò",
      "Gaglioppo",
      "Greco di Bianco",
      "Lamezia",
      "Melissa",
      "Sant'Anna di Isola Capo Rizzuto",
      "Savuto",
      "Scavigna",
      "Terre di Cosenza"
    ],
    "Campania" => [
      "Avellino",
      "Benevento",
      "Caserta",
      "Napoli",
      "Salerno"
    ],
    "Emilia-Romagna" => [
      "Colli Cesenate",
      "Sangiovese Superiore di Romagna",
      "Trebbiano di Romagna"
    ],
    "Liguria" => [
      "Cinque Terre"
    ],
    "Lombardy" => [
      "Franciacorta",
      "Oltrepo Pavese"
    ],
    "Marche" => [
      "Castelli di Jesi",
      "Conero",
      "Piceno"
    ],
    "Piedmont" => [
      "Acqui",
      "Alba",
      "Asti",
      "Barolo",
      "Colli Tortonesi",
      "Gattinara",
      "Gavi",
      "Ghemme",
      "Langhe",
      "Monferrato",
      "Nizza",
      "Ovada"
    ],
    "Sardinia" => [
      "Cagliari",
      "Cannonau",
      "Monti",
      "Nuragus",
      "Ogliastra",
      "Vermentino di Gallura"
    ],
    "Sicily" => [
      "Etna",
      "Noto",
      "Pantelleria"
    ],
    "Trentino-Alto Adige" => [
      "South Tyrol",
      "Trentino"
    ],
    "Tuscany" => [
      "Bolgheri",
      "Chianti",
      "Chianti Classico",
      "Colli Apuani",
      "Colli Etruria Centrale",
      "Colline Lucchesi",
      "Elba",
      "Montalcino",
      "Montescudaio",
      "Parrina",
      "Pitigliano",
      "San Gimignano"
    ]
  },
  "Spain" => %{
    "Andalusia" => [
      "Condado de Huelva",
      "Jerez-Xeres-Sherry",
      "Málaga and Sierras de Málaga",
      "Manzanilla de Sanlúcar de Barrameda",
      "Montilla-Moriles"
    ],
    "Aragon" => [
      "Calatayud",
      "Campo de Borja",
      "Campo de Cariñena",
      "Cava",
      "Somontano"
    ],
    "Balearic Islands" => [
      "Binissalem-Mallorca",
      "Plà i Llevant"
    ],
    "Basque Country" => [
      "Alavan Txakoli",
      "Biscayan Txakoli",
      "Cava",
      "Getaria Txakoli",
      "Rioja (Alavesa)"
    ],
    "Canary Islands" => [
      "Abona",
      "El Hierro",
      "Gran Canaria",
      "La Gomera",
      "La Palma",
      "Lanzarote",
      "Tacoronte-Acentejo",
      "Valle de Güímar",
      "Valle de la Orotava",
      "Ycoden-Daute-Isora"
    ],
    "Castile and León" => [
      "Arlanza",
      "Arribes del Duero",
      "Bierzo",
      "Cava",
      "Cigales",
      "Espumosos de Castilla y León",
      "Ribera del Duero",
      "Rueda",
      "Tierra del Vino de Zamora",
      "Toro",
      "Valles de Benavente",
      "Tierra de León",
      "Valtiendas",
      "Vino de la Tierra Castilla y León"
    ],
    "Castile–La Mancha" => [
      "Almansa",
      "Dominio de Valdepusa",
      "Guijoso",
      "Jumilla",
      "La Mancha",
      "Manchuela",
      "Méntrida",
      "Mondéjar",
      "Ribera del Júcar",
      "Valdepeñas"
    ],
    "Catalonia" => [
      "Alella",
      "Catalunya",
      "Cava",
      "Conca de Barberà",
      "Costers del Segre",
      "Empordà",
      "Montsant",
      "Penedès",
      "Pla de Bages",
      "Priorat",
      "Tarragona",
      "Terra Alta"
    ],
    "Extremadura" => [
      "Cava",
      "Ribera del Guadiana"
    ],
    "Galicia" => [
      "Monterrei",
      "Rías Baixas",
      "Ribeira Sacra",
      "Ribeiro",
      "Valdeorras"
    ],
    "La Rioja" => [
      "Cava",
      "Rioja"
    ],
    "Community of Madrid" => [
      "Vinos de Madrid"
    ],
    "Región de Murcia" => [
      "Bullas",
      "Jumilla",
      "Yecla"
    ],
    "Navarre" => [
      "Cava",
      "Navarra",
      "Rioja"
    ],
    "Valencian Community" => [
      "Alicante",
      "Cava",
      "Utiel-Requena",
      "Valencia"
    ]
  }
}

varietals = [
  "Aglianico",
  "Albana",
  "Albariño",
  "Aleatico",
  "Alfrocheiro",
  "Alicante Bouschet",
  "Aligoté",
  "Altesse",
  "Alvarelhão",
  "Antão Vaz",
  "Aragonês",
  "Arinto",
  "Arneis",
  "Assyrtico",
  "Auxerrois",
  "Avesso",
  "Baco Noir",
  "Baga",
  "Barbera",
  "Bical",
  "Black Muscat",
  "Blanc du Bois",
  "Blaufränkisch",
  "Bobal",
  "Bonarda",
  "Bordeaux-style Red Blend",
  "Bordeaux-style White Blend",
  "Brachetto",
  "Braucol",
  "Bual",
  "Cabernet Franc",
  "Cabernet Sauvignon",
  "Cannonau",
  "Carignan",
  "Carmenère",
  "Carricante",
  "Casavecchia",
  "Castelão",
  "Catarratto",
  "Cencibel",
  "Cerceal",
  "Chambourcin",
  "Champagne Blend",
  "Charbono",
  "Chardonnay",
  "Chasselas",
  "Chenin Blanc",
  "Ciliegiolo",
  "Cinsault",
  "Clairette",
  "Claret",
  "Coda di Volpe",
  "Colombard",
  "Cortese",
  "Corvina",
  "Counoise",
  "Dolcetto",
  "Dornfelder",
  "Duras",
  "Durif",
  "Encruzado",
  "Falanghina",
  "Fer Servadou",
  "Fernão Pires",
  "Feteasca Neagra",
  "Fiano",
  "Frappato",
  "Friulano",
  "Fumé Blanc",
  "Furmint",
  "Gaglioppo",
  "Gamay",
  "Garganega",
  "Gewürztraminer",
  "Glera (Prosecco)",
  "Godello",
  "Graciano",
  "Grauburgunder",
  "Grecanico",
  "Grechetto",
  "Greco / Greco Bianco",
  "Grenache Blanc / Garnacha Blanca",
  "Grenache-Syrah-Mourvèdre",
  "Grenache / Garnacha",
  "Grillo",
  "Gros Manseng",
  "Grüner Veltliner",
  "Hárslevelű",
  "Hondarrabi Zuri",
  "Inzolia / Insolia",
  "Jacquère",
  "Jaen",
  "Kalecik Karasi",
  "Kékfrankos",
  "Kerner",
  "Lagrein",
  "Lambrusco",
  "Lemberger",
  "Loin de l'Oeil",
  "Loureiro",
  "Macabeo",
  "Madeira Blend",
  "Magliocco",
  "Malagousia",
  "Malbec",
  "Malvasia",
  "Mantonico",
  "Manzoni",
  "Marsanne",
  "Marzemino",
  "Mataro",
  "Maturana",
  "Mauzac",
  "Mavrodaphne",
  "Mavrud",
  "Melon",
  "Mencía",
  "Meritage",
  "Merlot",
  "Mission",
  "Molinara",
  "Monastrell",
  "Mondeuse",
  "Monica",
  "Montepulciano",
  "Morillon",
  "Moscadello",
  "Moscatel",
  "Moscatel Roxo",
  "Moschofilero",
  "Mourvèdre",
  "Mtsvane",
  "Müller-Thurgau",
  "Muscadelle / Muscadel",
  "Muscat / Moscato",
  "Narince",
  "Nascetta",
  "Nebbiolo",
  "Negrette",
  "Negroamaro",
  "Nerello Cappuccio",
  "Nerello Mascalese",
  "Nero d'Avola",
  "Nero di Troia",
  "Neuburger",
  "Norton",
  "Nosiola",
  "Nuragus",
  "Öküzgözü",
  "Orange Muscat",
  "Pallagrello",
  "Palomino",
  "Pansa Blanca",
  "Passerina",
  "Pecorino",
  "Pedro Ximénez",
  "Perricone",
  "Petit Manseng",
  "Petit Verdot",
  "Petite Sirah",
  "Picolit",
  "Picpoul",
  "Piedirosso",
  "Pignoletto",
  "Pinot Blanc / Pinot Bianco",
  "Pinot Grigio / Pinot Gris",
  "Pinot Meunier",
  "Pinot Noir / Pinot Nero",
  "Pinotage",
  "Plavac Mali",
  "Port",
  "Posip",
  "Prié Blanc",
  "Prieto Picudo",
  "Primitivo",
  "Prugnolo Gentile",
  "Raboso",
  "Red Blend",
  "Refosco",
  "Rhône-Style Red Blend",
  "Rhône-Style White Blend",
  "Ribolla Gialla",
  "Rieslaner",
  "Riesling",
  "Rivaner",
  "Rkatsiteli",
  "Robola",
  "Roditis",
  "Rolle",
  "Rosé",
  "Roter Veltliner",
  "Rotgipfler",
  "Roussanne",
  "Ruché",
  "Sagrantino",
  "Sämling",
  "Sangiovese",
  "Saperavi",
  "Sauvignon Blanc",
  "Sauvignon Gris",
  "Savagnin",
  "Savatiano",
  "Scheurebe",
  "Schiava",
  "Sémillon",
  "Seyval Blanc",
  "Sherry",
  "Siria",
  "Sousão",
  "Sparkling Blend",
  "Spätburgunder",
  "St. Laurent",
  "Susumaniello",
  "Sylvaner / Silvaner",
  "Symphony",
  "Syrah / Shiraz",
  "Tannat",
  "Tempranillo",
  "Tempranillo Blanco",
  "Teran",
  "Teroldego",
  "Tinta de Toro",
  "Tinta Fina / Tinto Fino",
  "Tinta Roriz",
  "Tinto del Pais",
  "Tokaji / Tokay",
  "Torrontés",
  "Touriga Franca",
  "Touriga Nacional",
  "Traminer",
  "Traminette",
  "Trebbiano",
  "Trepat",
  "Trincadeira",
  "Trousseau",
  "Turbiana",
  "Uva di Troia",
  "Valdiguié",
  "Verdeca",
  "Verdejo",
  "Verdelho",
  "Verdicchio",
  "Verduzzo Friulano / Verduzzo",
  "Vermentino",
  "Vernaccia",
  "Vidal Blanc",
  "Vignoles",
  "Vilana",
  "Viognier",
  "Viura",
  "Vranec",
  "Weissburgunder",
  "Welschriesling",
  "White Blend",
  "Xarel-lo",
  "Xinomavro",
  "Zibibbo",
  "Zierfandler",
  "Zinfandel"
]

varietals
|> Enum.each(fn varietal ->
  {:ok, _new_varietal} = Pour.Varietals.create_varietal(%{name: varietal})
end)

1800..2030
|> Enum.each(fn year ->
  {:ok, _new_year} = Pour.Vintages.create_vintage(%{year: year})
end)

region_data
|> Enum.map(fn {country, regions} ->
  {:ok, new_country} = Pour.WineRegions.create_country(%{name: country})

  regions
  |> Enum.map(fn {region, sub_regions} ->
    {:ok, new_region} =
      Pour.WineRegions.create_region(%{name: region, country_id: new_country.id})

    sub_regions
    |> Enum.map(fn sub_region ->
      Pour.WineRegions.create_subregion(%{name: sub_region, region_id: new_region.id})
    end)
  end)
end)
