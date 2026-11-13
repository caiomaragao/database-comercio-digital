CREATE DATABASE db_comercio_digital; -- Cria o banco de dados chamado db_comercio_digital
USE db_comercio_digital; -- Seleciona o banco de dados para executar as próximas instruções

CREATE TABLE tb_endereco ( -- Inicia a criação da tabela de endereços
    id_endereco INT AUTO_INCREMENT PRIMARY KEY, -- Define o identificador único numérico do endereço, gerado automaticamente
    logradouro VARCHAR(100) NOT NULL, -- Armazena o nome da rua, avenida ou quadra (campo obrigatório)
    numero VARCHAR(10), -- Armazena o número do imóvel (campo opcional, permitindo nulo para imóveis sem número ou endereços rurais)
    complemento VARCHAR(50), -- Armazena informações adicionais como bloco, apartamento ou sala (campo opcional)
    bairro VARCHAR(50) NOT NULL, -- Armazena o nome do bairro (campo obrigatório)
    cidade VARCHAR(50) NOT NULL, -- Armazena o nome da cidade (campo obrigatório)
    uf CHAR(2) NOT NULL, -- Armazena a sigla do estado com exatamente 2 caracteres, como 'DF' ou 'SP' (obrigatório)
    cep VARCHAR(9) NOT NULL -- Armazena o CEP no formato '00000-000' (campo obrigatório)
); -- Finaliza a criação da tabela tb_endereco

CREATE TABLE tb_cliente ( -- Inicia a criação da tabela de clientes
    id_cliente INT AUTO_INCREMENT PRIMARY KEY, -- Define o identificador único numérico do cliente, gerado automaticamente
    nome VARCHAR(100) NOT NULL, -- Armazena o nome completo do cliente com até 100 caracteres (campo obrigatório)
    email VARCHAR(100) NOT NULL UNIQUE, -- Armazena o e-mail do cliente, obrigatório e único no sistema
    cpf VARCHAR(14) UNIQUE, -- Armazena o CPF no formato '000.000.000-00', único quando informado, mas opcional no cadastro inicial
    telefone VARCHAR(15), -- Armazena o telefone de contato no formato '(00) 90000-0000' (campo opcional)
    id_endereco INT, -- Cria a coluna opcional que armazenará o código do endereço do cliente, permitindo cadastro sem endereço inicial

    CONSTRAINT fk_cliente_endereco -- Nomeia a regra de chave estrangeira que relaciona cliente a endereço
        FOREIGN KEY (id_endereco) REFERENCES tb_endereco (id_endereco) -- Vincula a coluna id_endereco à chave primária da tabela tb_endereco
); -- Finaliza a criação da tabela tb_cliente

CREATE TABLE tb_pedido ( -- Inicia a criação da tabela de pedidos
    numero_pedido INT AUTO_INCREMENT PRIMARY KEY, -- Define o número identificador único do pedido, gerado automaticamente
    data_pedido DATE NOT NULL, -- Armazena a data em que o pedido foi realizado no formato 'AAAA-MM-DD' (obrigatório)
    status ENUM('Aguardando Pagamento', 'Pago', 'Em Separação', 'Enviado', 'Entregue', 'Cancelado') NOT NULL DEFAULT 'Aguardando Pagamento', -- Restringe os status válidos do pedido e inicia como 'Aguardando Pagamento'
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0.00, -- Armazena o valor total do pedido com 2 casas decimais, iniciando em 0.00
    id_cliente INT NOT NULL, -- Cria a coluna que identifica o cliente responsável pelo pedido (obrigatório)

    CONSTRAINT fk_pedido_cliente -- Nomeia a regra de chave estrangeira que relaciona pedido a cliente
        FOREIGN KEY (id_cliente) REFERENCES tb_cliente (id_cliente) -- Vincula a coluna id_cliente à chave primária da tabela tb_cliente
); -- Finaliza a criação da tabela tb_pedido

CREATE TABLE tb_pagamento ( -- Inicia a criação da tabela de pagamentos
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY, -- Define o identificador único do pagamento, gerado automaticamente
    forma_pagamento ENUM('PIX', 'Cartão de Crédito', 'Cartão de Débito', 'Boleto') NOT NULL, -- Padroniza os meios de pagamento aceitos pelo sistema (obrigatório)
    data_pagamento DATE NOT NULL, -- Armazena a data em que o pagamento foi efetuado no formato 'AAAA-MM-DD' (obrigatório)
    valor_pago DECIMAL(10,2) NOT NULL, -- Armazena o valor financeiro pago com precisão de 2 casas decimais (obrigatório)
    numero_pedido INT NOT NULL UNIQUE, -- Cria a coluna obrigatória e única do pedido vinculado, garantindo no máximo 1 pagamento por pedido

    CONSTRAINT fk_pagamento_pedido -- Nomeia a regra de chave estrangeira que relaciona pagamento a pedido
        FOREIGN KEY (numero_pedido) REFERENCES tb_pedido (numero_pedido) -- Vincula a coluna numero_pedido à chave primária da tabela tb_pedido
); -- Finaliza a criação da tabela tb_pagamento

CREATE TABLE tb_categoria ( -- Inicia a criação da tabela de categorias
    id_categoria INT AUTO_INCREMENT PRIMARY KEY, -- Define o identificador único da categoria, gerado automaticamente
    nome_categoria VARCHAR(50) NOT NULL UNIQUE, -- Armazena o nome da categoria, obrigatório e sem permitir nomes duplicados
    descricao VARCHAR(200) -- Armazena uma breve descrição da categoria com até 200 caracteres (campo opcional)
); -- Finaliza a criação da tabela tb_categoria

CREATE TABLE tb_produto ( -- Inicia a criação da tabela de produtos
    id_produto INT AUTO_INCREMENT PRIMARY KEY, -- Define o identificador único do produto, gerado automaticamente
    nome_produto VARCHAR(100) NOT NULL, -- Armazena o nome do produto com até 100 caracteres (campo obrigatório)
    preco DECIMAL(10,2) NOT NULL, -- Armazena o preço unitário de venda do produto com 2 casas decimais (obrigatório)
    estoque INT NOT NULL DEFAULT 0, -- Armazena a quantidade disponível em estoque como número inteiro, iniciando em 0
    id_categoria INT, -- Cria a coluna opcional que identifica a categoria do produto, permitindo cadastrar produtos antes de categorizá-los

    CONSTRAINT fk_produto_categoria -- Nomeia a regra de chave estrangeira que relaciona produto a categoria
        FOREIGN KEY (id_categoria) REFERENCES tb_categoria (id_categoria) -- Vincula a coluna id_categoria à chave primária da tabela tb_categoria
); -- Finaliza a criação da tabela tb_produto

CREATE TABLE tb_contem ( -- Inicia a criação da tabela associativa que registra os itens de cada pedido
    id_contem INT AUTO_INCREMENT PRIMARY KEY, -- Define o identificador único de cada linha de item do pedido, gerado automaticamente
    numero_pedido INT NOT NULL, -- Cria a coluna que referencia o pedido ao qual o item pertence (obrigatório)
    id_produto INT NOT NULL, -- Cria a coluna que referencia o produto incluído no pedido (obrigatório)
    quantidade INT NOT NULL DEFAULT 1, -- Armazena a quantidade comprada daquele produto no pedido, iniciando em 1
    preco_unitario DECIMAL(10,2) NOT NULL, -- Armazena o preço unitário praticado no momento da compra para preservar o histórico

    CONSTRAINT fk_contem_pedido -- Nomeia a regra de chave estrangeira que vincula o item ao pedido
        FOREIGN KEY (numero_pedido) REFERENCES tb_pedido (numero_pedido), -- Vincula a coluna numero_pedido à chave primária da tabela tb_pedido
    CONSTRAINT fk_contem_produto -- Nomeia a regra de chave estrangeira que vincula o item ao produto
        FOREIGN KEY (id_produto) REFERENCES tb_produto (id_produto) -- Vincula a coluna id_produto à chave primária da tabela tb_produto
); -- Finaliza a criação da tabela tb_contem

-- 1. INSERÇÃO NA TABELA CATEGORIA
INSERT INTO tb_categoria (nome_categoria, descricao) VALUES -- Insere as categorias de produtos na tabela tb_categoria
('Hardware', 'Componentes internos para computadores, processadores, placas de vídeo e memórias'), -- Insere a Categoria 1
('Periféricos', 'Teclados mecânicos, mouses gamer, headsets e webcams'), -- Insere a Categoria 2
('Monitores', 'Monitores LED, IPS, ultrawide e telas de alta taxa de atualização'), -- Insere a Categoria 3
('Smartphones', 'Celulares Android e iOS de diversas marcas e capacidades'), -- Insere a Categoria 4
('Cadeiras e Escritório', 'Cadeiras ergonômicas, suportes articulados e mesas para setup'), -- Insere a Categoria 5
('Redes e Conectividade', 'Roteadores Wi-Fi 6, switches, cabos de rede e adaptadores'), -- Insere a Categoria 6
('Armazenamento', 'SSDs NVMe, HDs externos e cartões de memória'), -- Insere a Categoria 7
('Realidade Virtual', 'Óculos VR e sensores de movimento (categoria vazia para testes de LEFT JOIN)'); -- Insere a Categoria 8

-- 2. INSERÇÃO NA TABELA ENDEREÇO
INSERT INTO tb_endereco (logradouro, numero, complemento, bairro, cidade, uf, cep) VALUES -- Insere os endereços na tabela tb_endereco
('SQN 308 Bloco D', NULL, 'Apto 204', 'Asa Norte', 'Brasília', 'DF', '70747-040'), -- Insere o Endereço 1
('Quadra 102 Conjunto 5', '14', 'Casa B', 'Águas Claras', 'Brasília', 'DF', '71907-180'), -- Insere o Endereço 2
('Avenida Paulista', '1578', 'Conjunto 82', 'Bela Vista', 'São Paulo', 'SP', '01310-200'), -- Insere o Endereço 3
('Rua Augusta', '2410', NULL, 'Cerqueira César', 'São Paulo', 'SP', '01412-100'), -- Insere o Endereço 4
('Rua Visconde de Pirajá', '414', 'Sala 301', 'Ipanema', 'Rio de Janeiro', 'RJ', '22410-002'), -- Insere o Endereço 5
('Avenida Atlântica', '1702', 'Apto 901', 'Copacabana', 'Rio de Janeiro', 'RJ', '22021-001'), -- Insere o Endereço 6
('Avenida Afonso Pena', '3130', NULL, 'Cruzeiro', 'Belo Horizonte', 'MG', '30130-009'), -- Insere o Endereço 7
('Rua da Bahia', '1148', 'Loja 12', 'Centro', 'Belo Horizonte', 'MG', '30160-011'), -- Insere o Endereço 8
('Avenida Sete de Setembro', '1850', 'Apto 502', 'Vitória', 'Salvador', 'BA', '40080-001'), -- Insere o Endereço 9
('SHIS QI 15 Conjunto 3', '22', NULL, 'Lago Sul', 'Brasília', 'DF', '71635-230'), -- Insere o Endereço 10
('Rua Oscar Freire', '720', 'Sobreloja', 'Jardins', 'São Paulo', 'SP', '01426-001'), -- Insere o Endereço 11
('Avenida das Américas', '4666', 'Bloco B Sala 110', 'Barra da Tijuca', 'Rio de Janeiro', 'RJ', '22640-102'), -- Insere o Endereço 12
('Rodovia DF-001 KM 18', NULL, 'Chácara Santa Luzia', 'Jardim Botânico', 'Brasília', 'DF', '71680-369'), -- Insere o Endereço 13
('Rua XV de Novembro', '890', NULL, 'Centro', 'Curitiba', 'PR', '80060-000'), -- Insere o Endereço 14
('Avenida Boa Viagem', '3450', 'Apto 1201', 'Boa Viagem', 'Recife', 'PE', '51020-001'); -- Insere o Endereço 15

-- 3. INSERÇÃO NA TABELA CLIENTE
INSERT INTO tb_cliente (nome, email, cpf, telefone, id_endereco) VALUES -- Insere os clientes na tabela tb_cliente
('Lucas Andrade Silva', 'lucas.andrade@email.com', '123.456.789-01', '(61) 99123-4501', 1), -- Insere o Cliente 1
('Mariana Costa Ferreira', 'mariana.ferreira@email.com', '234.567.890-12', '(61) 99234-5602', 2), -- Insere o Cliente 2
('Rafael Oliveira Santos', 'rafael.santos@email.com', '345.678.901-23', '(11) 98345-6703', 3), -- Insere o Cliente 3
('Camila Almeida Rocha', 'camila.rocha@email.com', '456.789.012-34', '(11) 98456-7804', 4), -- Insere o Cliente 4
('Bruno Carvalho Lima', 'bruno.lima@email.com', '567.890.123-45', '(21) 97567-8905', 5), -- Insere o Cliente 5
('Juliana Mendes Souza', 'juliana.souza@email.com', '678.901.234-56', '(21) 97678-9006', 6), -- Insere o Cliente 6
('Gabriel Martins Pereira', 'gabriel.pereira@email.com', '789.012.345-67', '(31) 99789-0107', 7), -- Insere o Cliente 7
('Fernanda Ribeiro Alves', 'fernanda.alves@email.com', '890.123.456-78', '(31) 99890-1208', 8), -- Insere o Cliente 8
('Thiago Barbosa Dias', 'thiago.dias@email.com', '901.234.567-89', '(71) 98901-2309', 9), -- Insere o Cliente 9
('Beatriz Gomes Nogueira', 'beatriz.nogueira@email.com', '012.345.678-90', '(61) 98012-3410', 10), -- Insere o Cliente 10
('Pedro Henrique Castro', 'pedro.castro@email.com', '111.222.333-44', '(11) 97111-2211', 11), -- Insere o Cliente 11
('Larissa Teixeira Pinto', 'larissa.pinto@email.com', '222.333.444-55', '(21) 96222-3312', 12), -- Insere o Cliente 12
('Matheus Correia Melo', 'matheus.melo@email.com', '333.444.555-66', '(61) 99333-4413', 13), -- Insere o Cliente 13
('Amanda Vieira Cardoso', 'amanda.cardoso@email.com', '444.555.666-77', '(41) 99444-5514', 14), -- Insere o Cliente 14
('Rodrigo Monteiro Nunes', 'rodrigo.nunes@email.com', '555.666.777-88', '(81) 98555-6615', 15), -- Insere o Cliente 15
('Isabela Freitas Duarte', 'isabela.duarte@email.com', NULL, '(61) 98666-7716', 1), -- Insere o Cliente 16
('Felipe Azevedo Moreira', 'felipe.moreira@email.com', '777.888.999-00', NULL, NULL), -- Insere o Cliente 17
('Carolina Farias Borges', 'carolina.borges@email.com', NULL, '(11) 99888-9918', NULL), -- Insere o Cliente 18
('Diego Cunha Rezende', 'diego.rezende@email.com', '888.999.000-11', '(31) 98999-0019', 7), -- Insere o Cliente 19
('Patrícia Lopes Tavares', 'patricia.tavares@email.com', '999.000.111-22', '(61) 98111-0020', 2); -- Insere o Cliente 20

-- 4. INSERÇÃO NA TABELA PRODUTO
INSERT INTO tb_produto (nome_produto, preco, estoque, id_categoria) VALUES -- Insere os produtos na tabela tb_produto
('Processador AMD Ryzen 7 7800X3D', 2499.90, 15, 1), -- Insere o Produto 1
('Placa de Vídeo RTX 4070 Super 12GB', 4199.00, 8, 1), -- Insere o Produto 2
('Memória RAM DDR5 32GB (2x16GB) 6000MHz', 849.90, 25, 1), -- Insere o Produto 3
('Placa-Mãe B650M Wi-Fi AM5', 1190.00, 12, 1), -- Insere o Produto 4
('Teclado Mecânico Keychron K2 Wireless', 620.00, 30, 2), -- Insere o Produto 5
('Mouse Gamer Logitech G Pro X Superlight', 749.90, 18, 2), -- Insere o Produto 6
('Headset HyperX Cloud III Wireless', 899.00, 0, 2), -- Insere o Produto 7
('Webcam Logitech Brio 4K Ultra HD', 1050.00, 10, 2), -- Insere o Produto 8
('Monitor Gamer LG UltraGear 27" 144Hz IPS', 1399.00, 14, 3), -- Insere o Produto 9
('Monitor Dell UltraSharp 27" 4K USB-C', 3290.00, 6, 3), -- Insere o Produto 10
('Monitor Ultrawide Samsung 34" Curvo', 2199.00, 9, 3), -- Insere o Produto 11
('Smartphone Samsung Galaxy S24 Ultra 256GB', 5899.00, 11, 4), -- Insere o Produto 12
('iPhone 15 128GB Preto', 4799.00, 16, 4), -- Insere o Produto 13
('Smartphone Motorola Edge 50 Pro 256GB', 2699.00, 20, 4), -- Insere o Produto 14
('Cadeira Ergonômica Herman Miller Aeron', 8500.00, 3, 5), -- Insere o Produto 15
('Cadeira Gamer ThunderX3 EC3 Preta', 1150.00, 19, 5), -- Insere o Produto 16
('Suporte Articulado ELG F80N para Monitor', 189.90, 45, 5), -- Insere o Produto 17
('Roteador TP-Link Archer AX73 Wi-Fi 6', 549.90, 22, 6), -- Insere o Produto 18
('Cabo de Rede Cat6 Furukawa 10 Metros', 49.90, 80, 6), -- Insere o Produto 19
('SSD NVMe Kingston Fury Renegade 1TB', 599.90, 35, 7), -- Insere o Produto 20
('HD Externo Seagate Expansion 2TB USB 3.0', 429.90, 28, 7), -- Insere o Produto 21
('Kit Limpeza de Telas e Eletrônicos 120ml', 39.90, 50, NULL); -- Insere o Produto 22

-- 5. INSERÇÃO NA TABELA PEDIDO
INSERT INTO tb_pedido (data_pedido, status, valor_total, id_cliente) VALUES -- Insere os pedidos na tabela tb_pedido
('2026-08-05', 'Entregue', 6698.90, 1), -- Insere o Pedido 1
('2026-08-12', 'Entregue', 1369.90, 2), -- Insere o Pedido 2
('2026-08-19', 'Entregue', 5899.00, 3), -- Insere o Pedido 3
('2026-08-25', 'Cancelado', 1150.00, 4), -- Insere o Pedido 4
('2026-09-02', 'Entregue', 1588.90, 5), -- Insere o Pedido 5
('2026-09-07', 'Entregue', 4799.00, 6), -- Insere o Pedido 6
('2026-09-14', 'Entregue', 3479.90, 1), -- Insere o Pedido 7
('2026-09-18', 'Entregue', 8500.00, 7), -- Insere o Pedido 8
('2026-09-23', 'Entregue', 649.70, 8), -- Insere o Pedido 9
('2026-09-29', 'Enviado', 2699.00, 9), -- Insere o Pedido 10
('2026-10-03', 'Entregue', 2039.90, 10), -- Insere o Pedido 11
('2026-10-08', 'Entregue', 1199.80, 11), -- Insere o Pedido 12
('2026-10-12', 'Cancelado', 899.00, 12), -- Insere o Pedido 13
('2026-10-15', 'Entregue', 2199.00, 13), -- Insere o Pedido 14
('2026-10-19', 'Enviado', 1649.90, 14), -- Insere o Pedido 15
('2026-10-22', 'Pago', 429.90, 15), -- Insere o Pedido 16
('2026-10-26', 'Entregue', 1239.90, 2), -- Insere o Pedido 17
('2026-10-30', 'Pago', 5389.00, 3), -- Insere o Pedido 18
('2026-11-02', 'Em Separação', 1339.90, 5), -- Insere o Pedido 19
('2026-11-04', 'Pago', 79.80, 17), -- Insere o Pedido 20
('2026-11-06', 'Aguardando Pagamento', 4199.00, 1), -- Insere o Pedido 21
('2026-11-08', 'Aguardando Pagamento', 1399.00, 6), -- Insere o Pedido 22
('2026-11-10', 'Aguardando Pagamento', 2499.90, 10), -- Insere o Pedido 23
('2026-11-11', 'Aguardando Pagamento', 549.90, 18), -- Insere o Pedido 24
('2026-11-12', 'Aguardando Pagamento', 1050.00, 7); -- Insere o Pedido 25

-- 6. INSERÇÃO NA TABELA PAGAMENTO
INSERT INTO tb_pagamento (forma_pagamento, data_pagamento, valor_pago, numero_pedido) VALUES -- Insere os pagamentos na tabela tb_pagamento
('Cartão de Crédito', '2026-08-05', 6698.90, 1), -- Insere o pagamento do pedido 1
('PIX', '2026-08-12', 1369.90, 2), -- Insere o pagamento do pedido 2
('Cartão de Crédito', '2026-08-19', 5899.00, 3), -- Insere o pagamento do pedido 3
('PIX', '2026-09-02', 1588.90, 5), -- Insere o pagamento do pedido 5
('Cartão de Crédito', '2026-09-07', 4799.00, 6), -- Insere o pagamento do pedido 6
('Boleto', '2026-09-16', 3479.90, 7), -- Insere o pagamento do pedido 7
('Cartão de Crédito', '2026-09-18', 8500.00, 8), -- Insere o pagamento do pedido 8
('PIX', '2026-09-23', 649.70, 9), -- Insere o pagamento do pedido 9
('Cartão de Débito', '2026-09-29', 2699.00, 10), -- Insere o pagamento do pedido 10
('PIX', '2026-10-03', 2039.90, 11), -- Insere o pagamento do pedido 11
('Cartão de Crédito', '2026-10-08', 1199.80, 12), -- Insere o pagamento do pedido 12
('Boleto', '2026-10-17', 2199.00, 14), -- Insere o pagamento do pedido 14
('PIX', '2026-10-19', 1649.90, 15), -- Insere o pagamento do pedido 15
('Cartão de Débito', '2026-10-22', 429.90, 16), -- Insere o pagamento do pedido 16
('PIX', '2026-10-26', 1239.90, 17), -- Insere o pagamento do pedido 17
('Cartão de Crédito', '2026-10-30', 5389.00, 18), -- Insere o pagamento do pedido 18
('PIX', '2026-11-02', 1339.90, 19), -- Insere o pagamento do pedido 19
('PIX', '2026-11-04', 79.80, 20); -- Insere o pagamento do pedido 20

-- 7. INSERÇÃO NA TABELA CONTÉM
INSERT INTO tb_contem (numero_pedido, id_produto, quantidade, preco_unitario) VALUES -- Insere os itens de cada pedido na tabela tb_contem
(1, 1, 1, 2499.90), -- Insere 1 unidade do produto 1 no pedido 1
(1, 2, 1, 4199.00), -- Insere 1 unidade do produto 2 no pedido 1
(2, 5, 1, 620.00), -- Insere 1 unidade do produto 5 no pedido 2
(2, 6, 1, 749.90), -- Insere 1 unidade do produto 6 no pedido 2
(3, 12, 1, 5899.00), -- Insere 1 unidade do produto 12 no pedido 3
(4, 16, 1, 1150.00), -- Insere 1 unidade do produto 16 no pedido 4
(5, 9, 1, 1399.00), -- Insere 1 unidade do produto 9 no pedido 5
(5, 17, 1, 189.90), -- Insere 1 unidade do produto 17 no pedido 5
(6, 13, 1, 4799.00), -- Insere 1 unidade do produto 13 no pedido 6
(7, 10, 1, 3290.00), -- Insere 1 unidade do produto 10 no pedido 7
(7, 17, 1, 189.90), -- Insere 1 unidade do produto 17 no pedido 7
(8, 15, 1, 8500.00), -- Insere 1 unidade do produto 15 no pedido 8
(9, 18, 1, 549.90), -- Insere 1 unidade do produto 18 no pedido 9
(9, 19, 2, 49.90), -- Insere 2 unidades do produto 19 no pedido 9
(10, 14, 1, 2699.00), -- Insere 1 unidade do produto 14 no pedido 10
(11, 4, 1, 1190.00), -- Insere 1 unidade do produto 4 no pedido 11
(11, 3, 1, 849.90), -- Insere 1 unidade do produto 3 no pedido 11
(12, 20, 2, 599.90), -- Insere 2 unidades do produto 20 no pedido 12
(13, 7, 1, 899.00), -- Insere 1 unidade do produto 7 no pedido 13
(14, 11, 1, 2199.00), -- Insere 1 unidade do produto 11 no pedido 14
(15, 8, 1, 1050.00), -- Insere 1 unidade do produto 8 no pedido 15
(15, 20, 1, 599.90), -- Insere 1 unidade do produto 20 no pedido 15
(16, 21, 1, 429.90), -- Insere 1 unidade do produto 21 no pedido 16
(17, 8, 1, 1050.00), -- Insere 1 unidade do produto 8 no pedido 17
(17, 17, 1, 189.90), -- Insere 1 unidade do produto 17 no pedido 17
(18, 2, 1, 4199.00), -- Insere 1 unidade do produto 2 no pedido 18
(18, 4, 1, 1190.00), -- Insere 1 unidade do produto 4 no pedido 18
(19, 16, 1, 1150.00), -- Insere 1 unidade do produto 16 no pedido 19
(19, 17, 1, 189.90), -- Insere 1 unidade do produto 17 no pedido 19
(20, 22, 2, 39.90), -- Insere 2 unidades do produto 22 no pedido 20
(21, 2, 1, 4199.00), -- Insere 1 unidade do produto 2 no pedido 21
(22, 9, 1, 1399.00), -- Insere 1 unidade do produto 9 no pedido 22
(23, 1, 1, 2499.90), -- Insere 1 unidade do produto 1 no pedido 23
(24, 18, 1, 549.90), -- Insere 1 unidade do produto 18 no pedido 24
(25, 8, 1, 1050.00); -- Insere 1 unidade do produto 8 no pedido 25

-- ============================================================================
-- CONSULTAS DE VERIFICAÇÃO E ANÁLISE (QUERIES)
-- ============================================================================

SELECT * FROM tb_cliente; -- Seleciona todas as colunas e registros da tabela de clientes

SELECT * FROM tb_endereco; -- Seleciona todas as colunas e registros da tabela de endereços

SELECT * FROM tb_pedido; -- Seleciona todas as colunas e registros da tabela de pedidos

SELECT * FROM tb_pagamento; -- Seleciona todas as colunas e registros da tabela de pagamentos

SELECT * FROM tb_categoria; -- Seleciona todas as colunas e registros da tabela de categorias

SELECT * FROM tb_produto; -- Seleciona todas as colunas e registros da tabela de produtos

SELECT * FROM tb_contem; -- Seleciona todas as colunas e registros da tabela associativa de itens de pedidos

SELECT cpf, email -- Seleciona apenas as colunas de CPF e e-mail
FROM tb_cliente; -- Indica que os dados serão buscados na tabela tb_cliente

SELECT DISTINCT preco_unitario -- Seleciona os preços unitários únicos (sem repetição) da tabela de itens
FROM tb_contem -- Indica a tabela de origem dos dados (tb_contem)
ORDER BY preco_unitario DESC; -- Ordena os resultados do maior preço para o menor (decrescente)

SELECT quantidade, preco_unitario, (quantidade * preco_unitario) as valor -- Seleciona quantidade, preço unitário e calcula o subtotal multiplicando ambos, exibindo como 'valor'
FROM tb_contem; -- Indica a tabela de origem dos dados (tb_contem)

SELECT data_pedido, status -- Seleciona a data e o status dos pedidos
FROM tb_pedido -- Indica a tabela de origem dos dados (tb_pedido)
WHERE status = 'Entregue'; -- Filtra apenas os registros cujo status seja exatamente 'Entregue'

SELECT nome_produto, preco -- Seleciona o nome e o preço dos produtos
FROM tb_produto -- Indica a tabela de origem dos dados (tb_produto)
WHERE preco <= 1000; -- Filtra apenas os produtos com preço menor ou igual a R$ 1.000,00

SELECT tb_pedido.numero_pedido, tb_pedido.status, tb_cliente.nome AS nome_cliente -- Seleciona número e status do pedido junto ao nome do cliente (apelidado de 'nome_cliente')
FROM tb_pedido JOIN tb_cliente -- Une as tabelas tb_pedido e tb_cliente
ON tb_pedido.id_cliente = tb_cliente.id_cliente -- Define a condição de junção igualando a chave estrangeira id_cliente à chave primária da tb_cliente
WHERE tb_pedido.status = 'Pago'; -- Filtra apenas os pedidos que estão com o status 'Pago'

SELECT tb_categoria.nome_categoria, tb_produto.nome_produto -- Seleciona o nome da categoria e o nome do produto
FROM tb_categoria JOIN tb_produto; -- Une as tabelas tb_categoria e tb_produto (Obs: sem a cláusula ON, gera um produto cartesiano cruzando todas as linhas)

SELECT tb_cliente.nome AS nome_cliente, COUNT(tb_pedido.numero_pedido) AS total_pedidos -- Seleciona o nome do cliente e conta quantos pedidos cada um possui
FROM tb_cliente -- Define tb_cliente como tabela principal da consulta
JOIN tb_pedido ON tb_cliente.id_cliente = tb_pedido.id_cliente -- Une com tb_pedido vinculando pelo identificador do cliente
GROUP BY tb_cliente.id_cliente, tb_cliente.nome; -- Agrupa os resultados por ID e nome do cliente para que a contagem funcione por pessoa

SELECT ROUND(AVG(tb_produto.preco), 2) AS media_preco, MAX(tb_produto.preco) AS maior_preco -- Calcula a média de preço arredondada em 2 casas decimais e busca o maior preço
FROM tb_produto; -- Indica a tabela de origem dos dados (tb_produto)

SELECT nome_produto, preco -- Seleciona o nome e o preço dos produtos
FROM tb_produto -- Indica a tabela de origem dos dados (tb_produto)
WHERE preco BETWEEN 500 AND 1500 AND estoque > 10 -- Filtra produtos com preço entre R$ 500 e R$ 1.500 que tenham mais de 10 unidades em estoque
ORDER BY preco DESC; -- Ordena os produtos filtrados do mais caro para o mais barato

SELECT MIN(tb_produto.preco) AS menor_preco -- Busca o menor valor encontrado na coluna preço, exibindo como 'menor_preco'
FROM tb_produto; -- Indica a tabela de origem dos dados (tb_produto)

SELECT SUM(tb_produto.estoque) AS total_geral_estoque -- Soma todas as quantidades da coluna estoque, exibindo como 'total_geral_estoque'
FROM tb_produto; -- Indica a tabela de origem dos dados (tb_produto)

-- ============================================================================
-- TRIGGERS E TESTES DE AUTOMAÇÃO
-- ============================================================================

DELIMITER $$ -- Altera o delimitador de comandos de ';' para '$$' para permitir o uso de ponto e vírgula dentro do bloco do trigger
CREATE TRIGGER trg_atualiza_estoque_e_total -- Cria o trigger chamado trg_atualiza_estoque_e_total
AFTER INSERT ON tb_contem -- Define que o trigger será executado imediatamente após uma inserção na tabela tb_contem
FOR EACH ROW -- Especifica que o bloco será executado para cada linha inserida individualmente
BEGIN -- Inicia o bloco de instruções do trigger
    UPDATE tb_produto -- Inicia a atualização de dados na tabela tb_produto
    SET estoque = estoque - NEW.quantidade -- Subtrai do estoque atual a quantidade que acabou de ser inserida no pedido (NEW.quantidade)
    WHERE id_produto = NEW.id_produto; -- Garante que a baixa ocorra apenas no produto correspondente ao item inserido
    UPDATE tb_pedido -- Inicia a atualização de dados na tabela tb_pedido
    SET valor_total = valor_total + (NEW.quantidade * NEW.preco_unitario) -- Soma ao valor total do pedido o subtotal do novo item inserido
    WHERE numero_pedido = NEW.numero_pedido; -- Garante que a soma ocorra apenas no pedido correspondente ao item inserido
END$$ -- Encerra o bloco de instruções do trigger
DELIMITER ; -- Restaura o delimitador padrão de comandos SQL para ';'

SELECT id_produto, nome_produto, estoque -- Seleciona o ID e o estoque atual do produto para verificação antes do teste
FROM tb_produto -- Indica a tabela tb_produto
WHERE id_produto = 19; -- Filtra especificamente o produto de ID 19 (Cabo de Rede)
 
SELECT numero_pedido, valor_total -- Seleciona o número e o valor total atual do pedido antes do teste
FROM tb_pedido -- Indica a tabela tb_pedido
WHERE numero_pedido = 24; -- Filtra especificamente o pedido de número 24

INSERT INTO tb_contem (numero_pedido, id_produto, quantidade, preco_unitario) -- Insere 1 unidade do produto 19 no pedido 24 (dispara o primeiro trigger)
VALUES (24, 19, 1, 49.90); -- Valores inseridos: pedido 24, produto 19, quantidade 1, preço 49.90

SELECT id_produto, nome_produto, estoque -- Consulta novamente o estoque do produto 19 para comprovar que foi reduzido em 1 unidade
FROM tb_produto -- Indica a tabela tb_produto
WHERE id_produto = 19; -- Filtra o produto de ID 19
 
SELECT numero_pedido, valor_total -- Consulta novamente o valor total do pedido 24 para comprovar que R$ 49,90 foram somados
FROM tb_pedido -- Indica a tabela tb_pedido
WHERE numero_pedido = 24; -- Filtra o pedido de número 24

DELIMITER $$ -- Altera o delimitador de comandos para '$$'
CREATE TRIGGER trg_confirma_pagamento_pedido -- Cria o trigger chamado trg_confirma_pagamento_pedido
AFTER INSERT ON tb_pagamento -- Define que o trigger será executado após a inserção de um registro na tabela tb_pagamento
FOR EACH ROW -- Especifica a execução linha a linha
BEGIN -- Inicia o bloco de instruções
    UPDATE tb_pedido -- Inicia a atualização na tabela tb_pedido
    SET status = 'Pago' -- Altera o status do pedido para 'Pago'
    WHERE numero_pedido = NEW.numero_pedido; -- Filtra o pedido correspondente ao pagamento recém-inserido
END$$ -- Encerra o bloco de instruções do trigger
DELIMITER ; -- Restaura o delimitador padrão para ';'

SELECT numero_pedido, status -- Consulta o status atual do pedido 24 antes do pagamento ('Aguardando Pagamento')
FROM tb_pedido -- Indica a tabela tb_pedido
WHERE numero_pedido = 24; -- Filtra o pedido de número 24

INSERT INTO tb_pagamento (forma_pagamento, data_pagamento, valor_pago, numero_pedido) -- Registra o pagamento via PIX para o pedido 24 (dispara o segundo trigger)
VALUES ('PIX', '2026-11-12', 549.90, 24); -- Valores inseridos: forma PIX, data, valor e pedido 24

SELECT numero_pedido, status -- Consulta novamente o pedido 24 para comprovar que o status mudou automaticamente para 'Pago'
FROM tb_pedido -- Indica a tabela tb_pedido
WHERE numero_pedido = 24; -- Filtra o pedido de número 24

DELIMITER $$ -- Altera o delimitador de comandos para '$$'
CREATE TRIGGER trg_valida_estoque_antes_do_item -- Cria o trigger chamado trg_valida_estoque_antes_do_item
BEFORE INSERT ON tb_contem -- Define que o trigger será executado ANTES de efetivar a inserção na tabela tb_contem
FOR EACH ROW -- Especifica a execução linha a linha
BEGIN -- Inicia o bloco de instruções
    DECLARE estoque_atual INT; -- Declara uma variável local inteira para armazenar o estoque disponível do produto

    SELECT estoque INTO estoque_atual -- Busca o valor do estoque no banco e salva dentro da variável estoque_atual
    FROM tb_produto -- Indica a tabela tb_produto
    WHERE id_produto = NEW.id_produto; -- Filtra o produto que está tentando ser inserido no pedido

    IF NEW.quantidade > estoque_atual THEN -- Verifica se a quantidade solicitada no pedido é maior que o estoque disponível
        SIGNAL SQLSTATE '45000' -- Interrompe a execução da inserção gerando um erro personalizado no MySQL
        SET MESSAGE_TEXT = 'Estoque insuficiente para a quantidade solicitada'; -- Define a mensagem de erro que será exibida ao usuário/sistema
    END IF; -- Finaliza a estrutura condicional IF
END$$ -- Encerra o bloco de instruções do trigger
DELIMITER ; -- Restaura o delimitador padrão para ';'

INSERT INTO tb_contem (numero_pedido, id_produto, quantidade, preco_unitario) -- Tenta inserir o produto 7 (que tem estoque 0) no pedido 24 para testar o bloqueio
VALUES (24, 7, 1, 899.00); -- Deve falhar exibindo a mensagem 'Estoque insuficiente para a quantidade solicitada'

INSERT INTO tb_contem (numero_pedido, id_produto, quantidade, preco_unitario) -- Insere 1 unidade do produto 19 (que possui estoque disponível) no pedido 24
VALUES (24, 19, 1, 49.90); -- Deve executar normalmente sem disparar erro

DELIMITER $$ -- Altera o delimitador de comandos para '$$'
CREATE TRIGGER trg_bloqueia_exclusao_pedido_pago -- Cria o trigger chamado trg_bloqueia_exclusao_pedido_pago
BEFORE DELETE ON tb_pedido -- Define que o trigger será executado ANTES de apagar um registro na tabela tb_pedido
FOR EACH ROW -- Especifica a execução linha a linha
BEGIN -- Inicia o bloco de instruções
    IF OLD.status IN ('Pago', 'Em Separação', 'Enviado', 'Entregue') THEN -- Verifica se o status antigo do pedido (OLD.status) indica que ele já foi pago
        SIGNAL SQLSTATE '45000' -- Interrompe o comando DELETE gerando um erro personalizado no MySQL
        SET MESSAGE_TEXT = 'Não é possível excluir um pedido já pago'; -- Define a mensagem de erro exibida ao tentar excluir o pedido
    END IF; -- Finaliza a estrutura condicional IF
END$$ -- Encerra o bloco de instruções do trigger
DELIMITER ; -- Restaura o delimitador padrão para ';'

DELETE -- Inicia o comando de exclusão de registro para testar o quarto trigger
FROM tb_pedido -- Indica a tabela tb_pedido
WHERE numero_pedido = 1; -- Tenta excluir o pedido 1 (que está com status 'Entregue', devendo gerar erro)

SELECT numero_pedido, status -- Consulta o pedido 1 para comprovar que ele permanece intacto no banco de dados
FROM tb_pedido -- Indica a tabela tb_pedido
WHERE numero_pedido = 1; -- Filtra o pedido de número 1