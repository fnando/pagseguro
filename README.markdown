PAGSEGURO
=========

Este é um plugin do Ruby on Rails que permite utilizar o [PagSeguro](https://pagseguro.uol.com.br/?ind=689659), gateway de pagamentos do [UOL](http://uol.com.br).

SOBRE O PAGSEGURO
-----------------

### Carrinho Próprio

Trabalhando com carrinho próprio, sua loja mantém os dados do carrinho. O processo de inclusão de produtos no carrinho de compras acontece no próprio site da loja. Quando o comprador quiser finalizar sua compra, ele é enviado ao PagSeguro uma única vez com todos os dados de seu pedido. Aqui também, você tem duas opções. Pode enviar os dados do pedido e deixar o PagSeguro solicitar os dados do comprador, ou pode solicitar todos os dados necessários para a compra em sua loja e enviá-los ao PagSeguro.

### Retorno Automático

Após o processo de compra e pagamento, o usuário é enviado de volta a seu site. Para isso, você deve configurar uma [URL de retorno](https://pagseguro.uol.com.br/Security/ConfiguracoesWeb/RetornoAutomatico.aspx).

Antes de enviar o usuário para essa URL, o robô do PagSeguro faz um POST para ela, em segundo plano, com os dados e status da transação. Lendo esse POST, você pode obter o status do pedido. Se o pagamento entrou em análise, ou se o usuário pagou usando boleto bancário, o status será "Aguardando Pagamento" ou "Em Análise". Nesses casos, quando a transação for confirmada (o que pode acontecer alguns dias depois) a loja receberá outro POST, informando o novo status. **Cada vez que a transação muda de status, um POST é enviado.**

COMO USAR
---------

### Configuração

O primeiro passo é instalar o plugin. Para isso, basta executar o comando abaixo na raíz de seu projeto.

	script/plugin install git://github.com/fnando/pagseguro.git

Se for utilizar o modo de desenvolvimento também precisará da gem Faker:

	sudo gem install faker

Depois de instalar o plugin, você precisará executar a rake abaixo; ela irá gerar o arquivo `config/pagseguro.yml`.

	rake pagseguro:setup

O arquivo de configuração gerado será parecido com isto:

	development: &development
	  developer: true
	  base: "http://localhost:3000"
	  return_to: "/pedido/efetuado"
	  email: user@example.com

	test:
	  <<: *development

	production:
	  authenticity_token: 9CA8D46AF0C6177CB4C23D76CAF5E4B0
	  email: user@example.com
	  return_to: "/pedido/efetuado"

Este plugin possui um modo de desenvolvimento que permite simular a realização de pedidos e envio de notificações; basta utilizar a opção `developer`. Ela é ativada por padrão nos ambientes de desenvolvimento e teste. Você deve configurar as opções `base`, que deverá apontar para o seu servidor e a URL de retorno, que deverá ser configurada no próprio [PagSeguro](https://pagseguro.uol.com.br/?ind=689659), na página <https://pagseguro.uol.com.br/Security/ConfiguracoesWeb/RetornoAutomatico.aspx>.

Para o ambiente de produção, que irá efetivamente enviar os dados para o [PagSeguro](https://pagseguro.uol.com.br/?ind=689659), você precisará adicionar o e-mail cadastrado como vendedor e o `authenticity_token`, que é o Token para Conferência de Segurança, que pode ser conseguido na página <https://pagseguro.uol.com.br/Security/ConfiguracoesWeb/RetornoAutomatico.aspx>.

### Montando o formulário

Para montar o seu formulário, você deverá utilizar a classe `PagSeguro::Order`. Esta classe deverá ser instanciada recebendo um identificador único do pedido. Este identificador permitirá identificar o pedido quando o [PagSeguro](https://pagseguro.uol.com.br/?ind=689659) notificar seu site sobre uma alteração no status do pedido.

	class CartController < ApplicationController
	  def checkout
	    # Busca o pedido associado ao usuário; esta lógica deve
	    # ser implementada por você, da maneira que achar melhor
		@invoice = current_user.invoices.last

		# Instanciando o objeto para geração do formulário
	    @order = PagSeguro::Order.new(@invoice.id)

	    # adicionando os produtos do pedido ao objeto do formulário
	    @invoice.products.each do |product|
	      # Estes são os atributos necessários. Por padrão, peso (:weight) é definido para 0,
		  # quantidade é definido como 1 e frete (:shipping) é definido como 0.
	      @order.add :id => product.id, :price => product.price, :description => product.title
	    end
	  end
	end

Se você precisar, pode definir o tipo de frete com o método `shipping_type`.

	@order.shipping_type = "SD" # Sedex
	@order.shipping_type = "EN" # PAC
	@order.shipping_type = "FR" # Frete Próprio

Depois que você definiu os produtos do pedido, você pode exibir o formulário.

	<!-- app/views/cart/checkout.html.erb -->
	<%= pagseguro_form @order, :submit => "Efetuar pagamento!" %>

Por padrão, o formulário é enviado para o email no arquivo de configuração. Você pode mudar o email com a opção `:email`.

	<%= pagseguro_form @order, :submit => "Efetuar pagamento!", :email => @account.email %>

### Recebendo notificações

Toda vez que o status de pagamento for alterado, o [PagSeguro](https://pagseguro.uol.com.br/?ind=689659) irá notificar sua URL de retorno com diversos dados. Você pode interceptar estas notificações com o método `pagseguro_notification`. O bloco receberá um objeto da class `PagSeguro::Notification` e só será executado se for uma notificação verificada junto ao [PagSeguro](https://pagseguro.uol.com.br/?ind=689659).

	class CartController < ApplicationController
	  skip_before_filter :verify_authenticity_token

	  def confirm
	    return unless request.post?

		pagseguro_notification do |notification|
		  # Aqui você deve verificar se o pedido possui os mesmos produtos
		  # que você cadastrou. O produto só deve ser liberado caso o status
		  # do pedido seja "completed" ou "approved"
		end

		render :nothing => true
	  end
	end

O método `pagseguro_notification` também pode receber como parâmetro o `authenticity_token` que será usado pra verificar a autenticação.

	class CartController < ApplicationController
	  skip_before_filter :verify_authenticity_token

	  def confirm
	    return unless request.post?
		# Se você receber pagamentos de contas diferentes, pode passar o
		# authenticity_token adequado como parâmetro para pagseguro_notification
		account = Account.find(params[:seller_id])
		pagseguro_notification(account.authenticity_token) do |notification|
		end

		render :nothing => true
	  end
	end

O objeto `notification` possui os seguintes métodos:

* `PagSeguro::Notification#products`: Lista de produtos enviados na notificação.
* `PagSeguro::Notification#shipping`: Valor do frete
* `PagSeguro::Notification#status`: Status do pedido
* `PagSeguro::Notification#payment_method`: Tipo de pagamento
* `PagSeguro::Notification#processed_at`: Data e hora da transação
* `PagSeguro::Notification#buyer`: Dados do comprador
* `PagSeguro::Notification#valid?(force=false)`: Verifica se a notificação é válido, confirmando-a junto ao PagSeguro. A resposta é jogada em cache e pode ser forçada com `PagSeguro::Notification#valid?(:force)`

**ATENÇÃO:** Não se esqueça de adicionar `skip_before_filter :verify_authenticity_token` ao controller que receberá a notificação; caso contrário, uma exceção será lançada.

### Utilizando modo de desenvolvimento

Toda vez que você enviar o formulário no modo de desenvolvimento, um arquivo YAML será criado em `tmp/pagseguro-#{RAILS_ENV}.yml`. Esse arquivo conterá todos os pedidos enviados.

Depois, você será redirecionado para a URL de retorno que você configurou no arquivo `config/pagseguro.yml`. Para simular o envio de notificações, você deve utilizar a rake `pagseguro:notify`.

	$ rake pagseguro:notify ID=<id do pedido>

O ID do pedido deve ser o mesmo que foi informado quando você instanciou a class `PagSeguro::Order`. Por padrão, o status do pedido será `completed` e o tipo de pagamento `credit_card`. Você pode especificar esses parâmetros como o exemplo abaixo.

	$ rake pagamento:notify ID=1 PAYMENT_METHOD=invoice STATUS=canceled NOTE="Enviar por motoboy" NAME="José da Silva"

#### PAYMENT_METHOD

* `credit_card`: Cartão de crédito
* `invoice`: Boleto
* `online_transfer`: Pagamento online
* `pagseguro`: Transferência entre contas do PagSeguro

#### STATUS

* `completed`: Completo
* `pending`: Aguardando pagamento
* `approved`: Aprovado
* `verifying`: Em análise
* `canceled`: Cancelado
* `refunded`: Devolvido

AUTOR:
------

Nando Vieira (<http://simplesideias.com.br>)

Recomendar no [Working With Rails](http://www.workingwithrails.com/person/7846-nando-vieira)

COLABORADORES:
--------------

* Elomar (<http://github.com/elomar>)
* Rafael (<http://github.com/rafaels>)

LICENÇA:
--------

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
