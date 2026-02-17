# Ubuntu Server: Swap + Early OOM

Script para configurar **swap** e **earlyoom** em Ubuntu Server de uma vez.

- Cria e ativa um arquivo de swap (padrão 8GB)
- Persiste o swap no `/etc/fstab`
- Define `vm.swappiness=10`
- Instala, habilita e inicia o **earlyoom** (evita OOM tardio do kernel)

## Uso rápido (copy & paste)

No servidor Ubuntu, rode como root:

```bash
curl -sSL https://raw.githubusercontent.com/erickythierry/ubuntu-swap-earlyoom/main/setup-swap-earlyoom.sh | sudo bash
```

### Swap com outro tamanho (ex.: 4GB)

```bash
SWAP_SIZE=4G curl -sSL https://raw.githubusercontent.com/erickythierry/ubuntu-swap-earlyoom/main/setup-swap-earlyoom.sh | sudo bash
```

## Uso manual

```bash
git clone https://github.com/erickythierry/ubuntu-swap-earlyoom.git
cd ubuntu-swap-earlyoom
sudo bash setup-swap-earlyoom.sh
```

## Requisitos

- Ubuntu Server (ou Debian com `apt`)
- Execução como root (`sudo`)

## O que o script faz

1. Cria `/swapfile` com o tamanho definido (padrão 8G)
2. Ativa o swap e adiciona entrada em `/etc/fstab`
3. Configura `vm.swappiness=10` e persiste em `/etc/sysctl.conf`
4. Instala o pacote `earlyoom`
5. Habilita e inicia o serviço `earlyoom`

O script é idempotente: se o swap ou as entradas já existirem, não duplica configurações.
