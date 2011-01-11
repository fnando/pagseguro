# -*- encoding: utf-8 -*-
module PagSeguro
  module Faker
    extend self

    NAMES = [
      "Agatha", "Alana", "Alexandre", "Alice", "Aline", "Alícia", "Amanda", "Ana", "Ana", "André",
      "Anthony", "Antônio", "Arthur", "Augusto", "Beatriz", "Benjamin", "Benício", "Bernardo",
      "Bianca", "Brenda", "Breno", "Bruna", "Bruno", "Bryan", "Bárbara", "Caio", "Calebe", "Camila",
      "Carlos", "Carolina", "Catarina", "Cecília", "Clara", "Clarice", "César", "Daniel", "Danilo",
      "Davi", "Diego", "Diogo", "Eduarda", "Eduardo", "Elisa", "Eloá", "Emanuel", "Emanuela",
      "Emily", "Enrico", "Enzo", "Erick", "Esther", "Evelyn", "Felipe", "Felipe", "Fernanda",
      "Fernando", "Francisco", "Gabriel", "Gabriela", "Giovanna", "Giovanni", "Guilherme",
      "Gustavo", "Heitor", "Helena", "Heloísa", "Henrique", "Henry", "Hugo", "Igor", "Isaac",
      "Isabel", "Isabella", "Isadora", "Joana", "Joaquim", "Jonathan", "João", "Juan", "Juliana",
      "Júlia", "Júlio", "Kamilly", "Kauã", "Kauê", "Kaíque", "Kevin", "Kyara", "Lara", "Larissa",
      "Laura", "Lavínia", "Laís", "Leonardo", "Letícia", "Levi", "Lorena", "Lorenzo", "Luan",
      "Luana", "Luca", "Lucas", "Luigi", "Luiz", "Luiza", "Luna", "Lívia", "Maitê", "Manuela",
      "Marcela", "Marco", "Marcos", "Maria", "Mariana", "Marina", "Matheus", "Melissa", "Miguel",
      "Milena", "Mirella", "Murilo", "Nathalia", "Nathan", "Nicolas", "Nicole", "Nina", "Olívia",
      "Otávio", "Paulo", "Pedro", "Pietra", "Rafael", "Rafaela", "Raquel", "Raul", "Rayssa",
      "Rebeca", "Renan", "Ricardo", "Rodrigo", "Ryan", "Sabrina", "Samuel", "Sarah", "Sophia",
      "Sophie", "Stefany", "Stella", "Thais", "Thayla", "Theo", "Thomas", "Tiago", "Valentina",
      "Vicente", "Vinicius", "Vitor", "Vitória", "Yago", "Yan", "Yasmin", "Yuri", "Ísis"
    ]

    SURNAMES = [
      "Abreu", "Aguiar", "Alencar", "Almeida", "Alves", "Amaral", "Ambrósio", "Amorim", "Amorim Neto",
      "Andrade", "Andrade Filho", "Antunes", "Aparício", "Araújo", "Assis", "Azevedo", "Baltazar",
      "Barbosa", "Bardini", "Barni", "Barra", "Barreto", "Barros", "Bastos", "Batista", "Belarmino",
      "Bento Da Silva", "Bezerra", "Bianchini", "Bittencourt", "Boaventura", "Bonfim", "Borges",
      "Braga", "Branco", "Brasil", "Brito", "Brunelli", "Cachoeira", "Caetano", "Camargo",
      "Campos", "Canella", "Cardoso", "Carvalho", "Castilho", "Castro", "Coelho", "Correia", "Costa",
      "Cândido", "de Sá", "Delfino", "do Vale", "Duarte", "Dutra", "Espindola", "Facchini", "Fagundes",
      "Farias", "Fernandes", "Ferreira", "Fonseca", "Fortunato", "Franz", "França", "Freitas",
      "Gomes", "Gonçalves", "Goulart", "Guedes", "Guerra", "Guimarães", "Hungaro", "Justino", "Leal",
      "Leite", "Lima", "Linhares", "Liz", "Lombardi", "Lopes", "Macedo", "Machado", "Maia", "Manhães",
      "Marques", "Martins", "Mendes", "Molinari", "Monteiro", "Morais", "Moreira", "Motta", "Neves",
      "Nunes", "Oliveira", "Pacheco", "Paiva", "Pinheiro", "Pinto", "Ribeiro", "Rocha", "Rodrigues",
      "Salles", "Santos", "Silva", "Souza", "Teixeira", "Vaz", "Ventura", "Vieira"
    ]

    CITIES = [
      "Augustinópolis", "Alegre", "Anitápolis", "Aroeiras do Itaim", "Auriflama", "Areia Branca",
      "Areial", "Avelinópolis", "Açucena", "Álvaro de Carvalho", "Araguaína", "Arroio do Tigre",
      "Anguera", "Águas Mornas", "Aquiraz", "Belmonte", "Barracão", "Barreira", "Belém de Maria",
      "Barra do Chapéu", "Bandeira do Sul", "Biquinhas", "Baependi", "Bela Vista de Goiás",
      "Buriti dos Montes", "Bom Lugar", "Brasil Novo", "Bocaiuva", "Bela Vista do Maranhão",
      "Bom Sucesso de Itararé", "Caridade", "Capela", "Colombo", "Celso Ramos", "Carmolândia",
      "Conceição do Castelo", "Camargo", "Carnaíba", "Carambeí", "Cametá", "Conceição de Macabu",
      "Coronel Martins", "Capela", "Campina Verde", "Curiúva", "Divisópolis", "Darcinópolis",
      "Divinolândia de Minas", "Dores do Turvo", "Dom Cavati", "Delfim Moreira", "Dobrada",
      "Dona Emma", "Dionísio", "Delmiro Gouveia", "Dona Inês", "Dom Feliciano", "Datas",
      "Divisa Alegre", "Dom Eliseu", "Ermo", "Escada", "Embaúba", "Encantado", "Elias Fausto",
      "Embu", "Espírito Santo", "Encruzilhada", "Engenheiro Paulo de Frontin", "Equador",
      "Erebango", "Estiva", "Esmeraldas", "Espera Feliz", "Eugênio de Castro", "Formoso", "Faro",
      "Frutuoso Gomes", "Formoso do Araguaia", "Floreal", "Francisco Alves", "Fartura do Piauí",
      "Ferreira Gomes", "Florestal", "Fontoura Xavier", "Fernandes Pinheiro", "Francisco Macedo",
      "Fortaleza dos Valos", "Formigueiro", "Feira Grande", "Granito", "Gália", "General Carneiro",
      "Graça", "Guarda-Mor", "Glória de Dourados", "Guarantã", "Gurjão", "Guareí",
      "Governador Eugênio Barros", "Guarani das Missões", "Guaíba", "Glorinha", "Gilbués",
      "Granja", "Horizontina", "Honório Serpa", "Hortolândia", "Heliópolis", "Horizonte",
      "Hugo Napoleão", "Holambra", "Heitoraí", "Humaitá", "Humberto de Campos", "Hulha Negra",
      "Humaitá", "Heliodora", "Herval", "Hidrolândia", "Itajá", "Inimutaba", "Itauçu",
      "Itaporã do Tocantins", "Ivoti", "Ipaussu", "Itapirapuã", "Itiúba", "Itatinga", "Ipanema",
      "Itaporanga", "Itamarati", "Itabira", "Imbé", "Iacri", "Japi", "Júlio Borges", "Jaciara",
      "Jesuânia", "Jenipapo dos Vieiras", "Jucurutu", "Jaguaquara", "Jacobina do Piauí",
      "Jaguariaíva", "Jaupaci", "Jatobá", "Juranda", "José Bonifácio", "Joaquim Távora",
      "Jandira", "Kaloré", "Lagoinha", "Lambari d'Oeste", "Luís Alves", "Limoeiro",
      "Lagoa do Piauí", "Liberato Salzano", "Luzerna", "Luciara", "Lindoeste", "Luislândia",
      "Lajedinho", "Luzinópolis", "Lapa", "Lagoa Santa", "Luís Gomes", "Maratá", "Muniz Ferreira",
      "Mato Verde", "Minaçu", "Marabá Paulista", "Monte Alegre", "Maripá", "Matias Cardoso",
      "Mirandópolis", "Moema", "Monsenhor Tabosa", "Minador do Negrão", "Monte Santo de Minas",
      "Miracatu", "Morada Nova", "Ninheira", "Nova União", "Niterói", "Nova Aurora", "Nova América",
      "Nova Era", "Nova Aliança do Ivaí", "Nova Santa Helena", "Natércia", "Nova Tebas", "Natuba",
      "Novo Hamburgo", "Nova Laranjeiras", "Neves Paulista", "Nova Candelária", "Ouro Velho",
      "Ouro Verde do Oeste", "Ouro Fino", "Ourilândia do Norte", "Oeiras do Pará",
      "Onça de Pitangui", "Oiapoque", "Óleo", "Olho d'Água do Piauí", "Olho d'Água do Casado",
      "Ocauçu", "Ouro Verde", "Oliveira Fortes", "Orobó", "Osvaldo Cruz", "Pacatuba", "Peabiru",
      "Portel", "Paverama", "Poção de Pedras", "Pirapemas", "Palestina", "Pedrinópolis",
      "Pirpirituba", "Pantano Grande", "Pitangueiras", "Paulistânia", "Paulistas",
      "Pedra Bonita", "Planalto da Serra", "Quixeré", "Quarto Centenário", "Quilombo",
      "Quixaba", "Quatis", "Quixadá", "Quissamã", "Queluzito", "Quixabeira", "Quijingue",
      "Quitandinha", "Queimada Nova", "Quixeramobim", "Queimadas", "Quinta do Sol", "Rio Preto",
      "Ronda Alta", "Rio Bananal", "Rio Rufino", "Rondolândia", "Riacho de Santo Antônio",
      "Rolim de Moura", "Riqueza", "Raposa", "Rio das Antas", "Riacho dos Machados", "Ribeirópolis",
      "Raul Soares", "Rio Grande da Serra", "Roseira", "São João", "Santa Rita do Sapucaí",
      "Salto do Jacuí", "Saúde", "Senador Georgino Avelino", "São Sebastião do Oeste", "São Pedro",
      "Santa Cecília", "São José dos Quatro Marcos", "Sapé", "São Felipe d'Oeste",
      "São Gonçalo do Amarante", "Siriri", "Sales Oliveira", "Santa Terezinha", "Timbó Grande",
      "Tamboara", "Taguaí", "Trairão", "Theobroma", "Taperoá", "Torre de Pedra", "Teutônia",
      "Taquarivaí", "Tanhaçu", "Tenório", "Três Lagoas", "Taperoá", "Terra Santa",
      "Tangará da Serra", "Urupá", "Uiraúna", "Uchoa", "Uruoca", "União", "Uruguaiana",
      "Uarini", "Ubaíra", "Una", "Urucará", "Uberaba", "Uru", "Umbuzeiro", "União Paulista",
      "Umuarama", "Varjota", "Virgolândia", "Viçosa do Ceará", "Vera Cruz", "Vespasiano",
      "Vista Gaúcha", "Vila Propício", "Vargem", "Vista Serrana", "Várzea Nova",
      "Visconde do Rio Branco", "Várzea da Roça", "Vicência", "Venâncio Aires", "Vera",
      "Witmarsum", "Wenceslau Guimarães", "Westfália", "Wenceslau Braz", "Wagner", "Wanderley",
      "Wenceslau Braz", "Wall Ferraz", "Wanderlândia", "Xapuri", "Xangri-lá", "Xinguara", "Xaxim",
      "Xambioá", "Xambrê", "Xexéu", "Xavantina", "Xanxerê", "Xique-Xique", "Zortéa", "Zabelê",
      "Zé Doca", "Zacarias"
    ]

    STATES = [
      "Acre", "Alagoas", "Amapá", "Amazonas", "Bahia", "Ceará", "Distrito Federal", "Espírito Santo",
      "Goiás", "Maranhão", "Mato Grosso", "Mato Grosso do Sul", "Minas Gerais", "Pará", "Paraíba",
      "Paraná", "Pernambuco", "Piauí", "Rio de Janeiro", "Rio Grande do Norte", "Rio Grande do Sul",
      "Rondônia", "Roraima", "Santa Catarina", "São Paulo", "Sergipe", "Tocantins"
    ]

    EMAILS = [
      "gmail.com", "yahoo.com.br", "hotmail.com", "uol.com.br", "ig.com.br", "bol.com.br"
    ]

    STREET_TYPES = ["Rua", "Avenida", "Estrada", "Alameda"]

    SECONDARY_ADDRESS = ["Apto", "Casa", "Bloco"]

    def street_name
      "#{STREET_TYPES.sample} #{CITIES.sample}"
    end

    def secondary_address
      "#{SECONDARY_ADDRESS.sample} #{rand(1000)}"
    end

    def phone_number(format = "(##) ####-####")
      format.gsub(/#/) { (1..9).to_a.sample }
    end

    def zipcode
      "#####-###".gsub(/#/) { (0..9).to_a.sample }
    end

    def email(base = nil)
      base ||= full_name
      base = normalize(base.downcase).gsub(/-/, ".")
      "#{base}@#{EMAILS.sample}"
    end

    def name
      NAMES.sample
    end

    def surname
      SURNAMES.sample
    end

    def full_name
      "#{name} #{surname}"
    end

    def city
      CITIES.sample
    end

    def state
      STATES.sample
    end

    private
    def normalize(str)
      str = ActiveSupport::Multibyte::Chars.new(str.dup)
      str = str.normalize(:kd).gsub(/[^\x00-\x7F]/, "").to_s
      str.gsub!(/[^-\w\d]+/xim, "-")
      str.gsub!(/-+/xm, "-")
      str.gsub!(/^-?(.*?)-?$/, '\1')
      str.downcase!
      str
    end
  end
end
