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

region_data
|> Enum.map(fn {country, regions} ->
  {:ok, new_country} = Pour.WineRegions.create_country(%{name: country})

  regions
  |> Enum.map(fn {region, sub_regions} ->
    {:ok, new_region} =
      Pour.WineRegions.create_region(%{name: region, country_id: new_country.id})

    sub_regions
    |> Enum.map(fn sub_region ->
      new_sub_region =
        Pour.WineRegions.create_subregion(%{name: sub_region, region_id: new_region.id})
    end)
  end)
end)
