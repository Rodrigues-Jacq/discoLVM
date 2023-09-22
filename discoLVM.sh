#!/bin/bash

echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo ++++++++++++++ Criação de Disco LVM +++++++++++++++++++
echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo
echo Lembre-se de ter adicionado o novo disco no sistema para que o mesmo possa ser adicionado.
echo
fdisk -l
read -p 'Informe qual o nome do novo disco, por exemplo, sdb: ' NOME_DISCO
if fdisk -l | grep /dev/$NOME_DISCO >/dev/null
then
	echo
	echo O disco informado existe.
	if dpkg -l | grep lvm2 >/dev/null
	then
		echo
		echo O pacote lvm2 já está instalado e seguiremos com o procedimento.
	else
		echo
		echo O pacote lvm2 não está instalado. O mesmo será instalado para continuarmos.
		apt install lvm2 -y
	fi
	echo
	read -p 'Informe o nome do VG (informe apenas o nome, exemplo, dados): ' NOME_VG
	vgcreate vg_$NOME_VG /dev/$NOME_DISCO
	read -p 'Informe o nome do LV (informe apenas o nome, exemplo, dados): ' NOME_LV
	lvcreate -l +100%FREE -n lv_$NOME_LV vg_$NOME_VG
	read -p 'Informe o nome do disco que será criado o diretório, por exemplo, dados, backup e outros: ' NOME_DISCO
	if mkfs.xfs >/dev/null
	then
		mkfs.xfs -L $NOME_DISCO /dev/vg_$NOME_VG/lv_$NOME_LV
	else
		apt install xfsprogs -y
		mkfs.xfs -L $NOME_DISCO /dev/vg_$NOME_VG/lv_$NOME_LV
	fi
	mkdir /$NOME_DISCO/
	echo /dev/mapper/vg_$NOME_VG-lv_$NOME_LV	/$NOME_DISCO/	xfs	defaults	0	0 >> /etc/fstab
	mount /$NOME_DISCO/
	echo
	df -h
	echo
	echo Disco criado com sucesso.
else
	echo
	echo O disco informado não existe, por favor, verifique o caso.
	echo O script será encerrado.
	echo Saindo...
fi
