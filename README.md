# AI Teacher

Esse projeto tem como objetivo ajudar pessoas a treinarem o seu "speaking" em diversas línguas com a ajuda de uma IA

O projeto utiliza as APIs da OpenAI, então para que você consiga utilizar esse código, você precisa ter uma conta na [OpenAI](https://openai.com/pricing)

# Requisitos

- Ter o Ruby instalado na máquina - https://www.ruby-lang.org/pt/
- Possuir uma chave de API da OpenAI - https://platform.openai.com/playground
- Adicionar o caminho do seu áudio em MP3 no código
- SO: Windows

Depois de instalar o Ruby, rodar os seguintes comandos:

```
gem install net/http
gem install oj
gem install json
gem install uri
```

# Execução

Estando na pasta do projeto basta rodar o seguinte comando: `ruby main.rb`

**Lembre-se de atualizar o código com a chave da API**

**Obs: Após executar o programa, você precisará utilizar algum gravador de áudio e salvar os áudios na pasta no formato "recording000x.mp3" onde x é o número sequencial do áudio: 1, 2, 3, etc...**
