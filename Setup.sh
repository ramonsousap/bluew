#!/bin/bash

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         BLUEW AUTOMATION                                      ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

versao() {
echo -e "                                   \e[97mVersão do Bluew: \e[32mv. 2.7.0\e[0m                                  "
echo -e "\e[32mbluew.automation.br/whatsapp2      \e[97m<----- Grupos no WhatsApp ----->     \e[32mbluew.automation.br/whatsapp3\e[0m"
}

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         BLUEW AUTOMATION                                      ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Cores do Setup

amarelo="\e[33m"
verde="\e[32m"
branco="\e[97m"
bege="\e[93m"
vermelho="\e[91m"
reset="\e[0m"

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         BLUEW AUTOMATION                                      ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

menu_instalador="1"

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         BLUEW AUTOMATION                                      ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

home_directory="$HOME"
dados_vps="${home_directory}/dados_vps/dados_vps"

dados() {
    nome_servidor=$(grep "Nome do Servidor:" "$dados_vps" | awk -F': ' '{print $2}')
    nome_rede_interna=$(grep "Rede interna:" "$dados_vps" | awk -F': ' '{print $2}')
}

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         BLUEW AUTOMATION                                      ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Licença do Setup

## cópia
direitos_setup() {
    echo -e "$amarelo===================================================================================================\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo=  $branco Este auto instalador foi desenvolvido para auxiliar na instalação das principais aplicações $amarelo  =\e[0m"
    echo -e "$amarelo=  $branco  disponíveis no mercado open source. Já deixo todos os créditos aos desenvolvedores de cada $amarelo  =\e[0m"
    echo -e "$amarelo=  $branco aplicação disponíveis aqui. Este Setup é licenciado sob a Licença MIT (MIT). Você pode usar, $amarelo =\e[0m"
    echo -e "$amarelo=  $branco  copiar, modificar, integrar, publicar, distribuir e/ou vender cópias dos produtos finais,  $amarelo  =\e[0m"
    echo -e "$amarelo=  $branco   mas deve sempre declarar que Bluew Automation (contato@bluew.automation.br) é o autor original  $amarelo  =\e[0m"
    echo -e "$amarelo=  $branco           destes códigos e atribuir um link para https://bluew.automation.br/setup           $amarelo  =\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
}

direitos_instalador() {
    echo -e "$amarelo===================================================================================================\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo=  $branco Este auto instalador foi desenvolvido para auxiliar na instalação das principais aplicações $amarelo  =\e[0m"
    echo -e "$amarelo=  $branco  disponíveis no mercado open source. Já deixo todos os créditos aos desenvolvedores de cada $amarelo  =\e[0m"
    echo -e "$amarelo=  $branco aplicação disponíveis aqui. Este Setup é licenciado sob a Licença MIT (MIT). Você pode usar, $amarelo =\e[0m"
    echo -e "$amarelo=  $branco  copiar, modificar, integrar, publicar, distribuir e/ou vender cópias dos produtos finais,  $amarelo  =\e[0m"
    echo -e "$amarelo=  $branco   mas deve sempre declarar que Bluew Automation (contato@bluew.automation.br) é o autor original  $amarelo  =\e[0m"
    echo -e "$amarelo=  $branco           destes códigos e atribuir um link para https://bluew.automation.br/setup           $amarelo  =\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
    read -p "Ao digitar Y você aceita e concorda com as orientações passadas acima (Y/N): " choice
    while true; do
        case $choice in
            Y|y)
                return
                ;;
            N|n)
                clear
                nome_finalizado
                echo "Que pena que você não concorda, então estarei encerrando o instalador. Até mais."
                sleep 2
                clear
                exit 1
                ;;
            *)
                clear
                erro_msg
                echo ""
                echo ""
                echo "Por favor, digite apenas Y ou N."
                sleep 2
                clear
                nome_instalador
                direitos_setup
                ;;
        esac
        read -p "Ao digitar Y você aceita e concorda com as orientações passadas acima (Y/N): " choice
    done
}

## Credenciais Portainerv2.5.0+
info_credenciais(){ 
    echo -e "$amarelo===================================================================================================\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo=  $branco A partir da versão 2.5.0 deste Setup foi implementado uma função para realizar deploy dentro $amarelo =\e[0m"
    echo -e "$amarelo=  $branco   do proprio portainer através de uma requisição api. Para que esta nova função funcione em  $amarelo =\e[0m"
    echo -e "$amarelo=  $branco suas proximas instalações, você precisará informar às credenciais de acesso do seu portainer $amarelo =\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
    
}

## Credito do Setup

creditos_msg() {
    echo ""
    echo ""
    echo -e "$amarelo===================================================================================================\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo=           $branco Gostaria de contribuir para continuarmos o desenvolvimento deste projeto?            $amarelo=\e[0m"
    echo -e "$amarelo=                              $branco Você pode fazer uma doação via PIX:                               $amarelo=\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo=                                     $amarelo pix@bluew.automation.br                                     $amarelo=\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo=          $branco Ou faça parte da nossa comunidade VIP no Discord e contribua com o projeto            $amarelo=\e[0m"
    echo -e "$amarelo=                       $branco Nossa comunidade:$amarelo https://join.bluew.automation.br                        $amarelo=\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo=                                   $branco Nossos grupos no WhatsApp                                    $amarelo=\e[0m"
    echo -e "$amarelo=      $amarelo https://bluew.automation.br/whatsapp2 $branco<-- ou -->$amarelo https://bluew.automation.br/whatsapp3      $amarelo=\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
}


## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         BLUEW AUTOMATION                                      ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Mensagens gerais

## Mensagem pedindo para preencher as informações

preencha_as_info() {
    echo -e "$amarelo===================================================================================================\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo=                          $branco Preencha as informações solicitadas abaixo                            $amarelo=\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
}

## Mensagem pedindo para verificar se as informações estão certas

conferindo_as_info() {
    echo -e "$amarelo===================================================================================================\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo=                          $branco Verifique se os dados abaixos estão certos                            $amarelo=\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
}

## Mensagem de Guarde os dados

guarde_os_dados_msg() {
    echo -e "$amarelo===================================================================================================\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo=                 $branco Guarde todos os dados abaixo para evitar futuros transtornos                   $amarelo=\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
}

## Mensagem de Instalando

instalando_msg() {
  echo""
  echo -e "$amarelo===================================================================================================\e[0m"
  echo -e "$amarelo=                                                                                                 =\e[0m"
  echo -e "$amarelo=      $branco  ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗      █████╗ ███╗   ██╗██████╗  ██████╗   $amarelo      = \e[0m" 
  echo -e "$amarelo=      $branco  ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗██╔═══██╗  $amarelo      =\e[0m"
  echo -e "$amarelo=      $branco  ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ███████║██╔██╗ ██║██║  ██║██║   ██║  $amarelo      =\e[0m"
  echo -e "$amarelo=      $branco  ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██╔══██║██║╚██╗██║██║  ██║██║   ██║  $amarelo      =\e[0m"
  echo -e "$amarelo=      $branco  ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝╚██████╔╝  $amarelo      =\e[0m"
  echo -e "$amarelo=      $branco  ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝   $amarelo      =\e[0m"
  echo -e "$amarelo=                                                                                                 =\e[0m"
  echo -e "$amarelo===================================================================================================\e[0m"
  echo ""
  echo ""
}

## Mensagem de Erro

erro_msg() {
   echo -e "$amarelo===================================================================================================\e[0m"
   echo -e "$amarelo=                                                                                                 =\e[0m"
   echo -e "$amarelo=                                 $branco███████╗██████╗ ██████╗  ██████╗                                $amarelo=\e[0m"
   echo -e "$amarelo=                                 $branco██╔════╝██╔══██╗██╔══██╗██╔═══██╗                               $amarelo=\e[0m"
   echo -e "$amarelo=                                 $branco█████╗  ██████╔╝██████╔╝██║   ██║                               $amarelo=\e[0m"
   echo -e "$amarelo=                                 $branco██╔══╝  ██╔══██╗██╔══██╗██║   ██║                               $amarelo=\e[0m"
   echo -e "$amarelo=                                 $branco███████╗██║  ██║██║  ██║╚██████╔╝                               $amarelo=\e[0m"
   echo -e "$amarelo=                                 $branco╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝                                $amarelo=\e[0m"
   echo -e "$amarelo=                                                                                                 =\e[0m"
   echo -e "$amarelo===================================================================================================\e[0m"
}

## Mensagem de Instalado

instalado_msg() {
    clear
    echo ""
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo -e "$branco     ██╗      ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗      █████╗ ██████╗  ██████╗       ██╗\e[0m"
    echo -e "$branco     ╚██╗     ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██╔══██╗██╔══██╗██╔═══██╗     ██╔╝\e[0m"
    echo -e "$branco      ╚██╗    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ███████║██║  ██║██║   ██║    ██╔╝ \e[0m"
    echo -e "$branco      ██╔╝    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██╔══██║██║  ██║██║   ██║    ╚██╗ \e[0m"
    echo -e "$branco     ██╔╝     ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗██║  ██║██████╔╝╚██████╔╝     ╚██╗\e[0m"
    echo -e "$branco     ╚═╝      ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝  ╚═════╝       ╚═╝\e[0m"
    echo ""
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
}

## Mensagem de Testando

nome_testando() {
    clear
    echo ""
    echo -e "$branco               ████████╗███████╗███████╗████████╗ █████╗ ███╗   ██╗██████╗  ██████╗ \e[0m"
    echo -e "$branco               ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝██╔══██╗████╗  ██║██╔══██╗██╔═══██╗\e[0m"
    echo -e "$branco                  ██║   █████╗  ███████╗   ██║   ███████║██╔██╗ ██║██║  ██║██║   ██║\e[0m"
    echo -e "$branco                  ██║   ██╔══╝  ╚════██║   ██║   ██╔══██║██║╚██╗██║██║  ██║██║   ██║\e[0m"
    echo -e "$branco                  ██║   ███████╗███████║   ██║   ██║  ██║██║ ╚████║██████╔╝╚██████╔╝\e[0m"
    echo -e "$branco                  ╚═╝   ╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝ \e[0m"
    echo ""
    echo ""
}
nome_credenciais() {
    clear
    echo ""
    echo -e "$branco          ██████╗██████╗ ███████╗██████╗ ███████╗███╗   ██╗ ██████╗██╗ █████╗ ██╗███████╗      \e[0m"
    echo -e "$branco         ██╔════╝██╔══██╗██╔════╝██╔══██╗██╔════╝████╗  ██║██╔════╝██║██╔══██╗██║██╔════╝      \e[0m"
    echo -e "$branco         ██║     ██████╔╝█████╗  ██║  ██║█████╗  ██╔██╗ ██║██║     ██║███████║██║███████╗      \e[0m"
    echo -e "$branco         ██║     ██╔══██╗██╔══╝  ██║  ██║██╔══╝  ██║╚██╗██║██║     ██║██╔══██║██║╚════██║      \e[0m"
    echo -e "$branco         ╚██████╗██║  ██║███████╗██████╔╝███████╗██║ ╚████║╚██████╗██║██║  ██║██║███████║      \e[0m"
    echo -e "$branco          ╚═════╝╚═╝  ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═══╝ ╚═════╝╚═╝╚═╝  ╚═╝╚═╝╚══════╝      \e[0m"
    echo -e "$branco                                                                                               \e[0m"
    echo -e "$branco   ██████╗  ██████╗     ██████╗  ██████╗ ██████╗ ████████╗ █████╗ ██╗███╗   ██╗███████╗██████╗ \e[0m"
    echo -e "$branco   ██╔══██╗██╔═══██╗    ██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝██╔══██╗██║████╗  ██║██╔════╝██╔══██╗\e[0m"
    echo -e "$branco   ██║  ██║██║   ██║    ██████╔╝██║   ██║██████╔╝   ██║   ███████║██║██╔██╗ ██║█████╗  ██████╔╝\e[0m"
    echo -e "$branco   ██║  ██║██║   ██║    ██╔═══╝ ██║   ██║██╔══██╗   ██║   ██╔══██║██║██║╚██╗██║██╔══╝  ██╔══██╗\e[0m"
    echo -e "$branco   ██████╔╝╚██████╔╝    ██║     ╚██████╔╝██║  ██║   ██║   ██║  ██║██║██║ ╚████║███████╗██║  ██║\e[0m"
    echo -e "$branco   ╚═════╝  ╚═════╝     ╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝\e[0m"
    echo ""
    echo ""
    info_credenciais
}
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         BLUEW AUTOMATION                                      ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Titulos

## Nome do instalador

nome_instalador() { 
    clear
    echo ""
    echo -e "$branco       ███████╗███████╗████████╗██╗   ██╗██████╗      ██████╗ ██████╗ ██╗ ██████╗ ███╗   ██╗\e[0m"
    echo -e "$branco       ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗    ██╔═══██╗██╔══██╗██║██╔═══██╗████╗  ██║\e[0m"
    echo -e "$branco       ███████╗█████╗     ██║   ██║   ██║██████╔╝    ██║   ██║██████╔╝██║██║   ██║██╔██╗ ██║\e[0m"
    echo -e "$branco       ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝     ██║   ██║██╔══██╗██║██║   ██║██║╚██╗██║\e[0m"
    echo -e "$branco       ███████║███████╗   ██║   ╚██████╔╝██║         ╚██████╔╝██║  ██║██║╚██████╔╝██║ ╚████║\e[0m"
    echo -e "$branco       ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝          ╚═════╝ ╚═╝  ╚═╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝\e[0m"
    echo -e "$branco                                                                                            \e[0m"
    echo -e "$branco                                  ██████╗ ███████╗  ██████╗                                 \e[0m"
    echo -e "$branco                                  ╚════██╗╚════██║ ██╔═████╗                                \e[0m"
    echo -e "$branco                        █████╗     █████╔╝    ██╔╝ ██║██╔██║    █████╗                      \e[0m"
    echo -e "$branco                        ╚════╝    ██╔═══╝    ██╔╝  ████╔╝██║    ╚════╝                      \e[0m"
    echo -e "$branco                                  ███████╗██╗██║██╗╚██████╔╝                                \e[0m"
    echo -e "$branco                                  ╚══════╝╚═╝╚═╝╚═╝ ╚═════╝                                 \e[0m"
    echo "" 
}

## Menu de ferramentas

nome_menu() {
    clear
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo -e "$branco                    ███╗   ███╗███████╗███╗   ██╗██╗   ██╗    ██████╗ ███████╗                \e[0m"
    echo -e "$branco                    ████╗ ████║██╔════╝████╗  ██║██║   ██║    ██╔══██╗██╔════╝                \e[0m"
    echo -e "$branco                    ██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║    ██║  ██║█████╗                  \e[0m"
    echo -e "$branco                    ██║╚██╔╝██║██╔══╝  ██║╚██╗██║██║   ██║    ██║  ██║██╔══╝                  \e[0m"
    echo -e "$branco                    ██║ ╚═╝ ██║███████╗██║ ╚████║╚██████╔╝    ██████╔╝███████╗                \e[0m"
    echo -e "$branco                    ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝     ╚═════╝ ╚══════╝                \e[0m"
    echo -e "$branco                                                                                                \e[0m"
    echo -e "$branco  ███████╗███████╗██████╗ ██████╗  █████╗ ███╗   ███╗███████╗███╗   ██╗████████╗ █████╗ ███████╗\e[0m"
    echo -e "$branco  ██╔════╝██╔════╝██╔══██╗██╔══██╗██╔══██╗████╗ ████║██╔════╝████╗  ██║╚══██╔══╝██╔══██╗██╔════╝\e[0m"
    echo -e "$branco  █████╗  █████╗  ██████╔╝██████╔╝███████║██╔████╔██║█████╗  ██╔██╗ ██║   ██║   ███████║███████╗\e[0m"
    echo -e "$branco  ██╔══╝  ██╔══╝  ██╔══██╗██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ██║╚██╗██║   ██║   ██╔══██║╚════██║\e[0m"
    echo -e "$branco  ██║     ███████╗██║  ██║██║  ██║██║  ██║██║ ╚═╝ ██║███████╗██║ ╚████║   ██║   ██║  ██║███████║\e[0m"
    echo -e "$branco  ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚══════╝\e[0m"
    echo ""
    echo -e "$amarelo===================================================================================================\e[0m"
    versao
    echo ""
}

## Titulo Teste de Email [0]

nome_testeemail() {
  clear
  echo ""
  echo -e "$branco                     ████████╗███████╗███████╗████████╗███████╗    ██████╗ ███████╗\e[0m"
  echo -e "$branco                     ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝██╔════╝    ██╔══██╗██╔════╝\e[0m"
  echo -e "$branco                        ██║   █████╗  ███████╗   ██║   █████╗      ██║  ██║█████╗  \e[0m"
  echo -e "$branco                        ██║   ██╔══╝  ╚════██║   ██║   ██╔══╝      ██║  ██║██╔══╝  \e[0m"
  echo -e "$branco                        ██║   ███████╗███████║   ██║   ███████╗    ██████╔╝███████╗\e[0m"
  echo -e "$branco                        ╚═╝   ╚══════╝╚══════╝   ╚═╝   ╚══════╝    ╚═════╝ ╚══════╝\e[0m"
  echo -e "$branco                                                                                   \e[0m"
  echo -e "$branco                                    ███████╗███╗   ███╗ █████╗ ██╗██╗                 \e[0m"
  echo -e "$branco                                    ██╔════╝████╗ ████║██╔══██╗██║██║                 \e[0m"
  echo -e "$branco                                    █████╗  ██╔████╔██║███████║██║██║                 \e[0m"
  echo -e "$branco                                    ██╔══╝  ██║╚██╔╝██║██╔══██║██║██║                 \e[0m"
  echo -e "$branco                                    ███████╗██║ ╚═╝ ██║██║  ██║██║███████╗            \e[0m"
  echo -e "$branco                                    ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝╚══════╝            \e[0m"
  echo ""
  echo ""                                                           
}
