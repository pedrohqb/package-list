/*
 * opensc-java.so: o OpenSC para o Java (PJeOffice Pro) no OpenBSD.
 *
 * O OpenSC informa que os mecanismos RSA assinam e decifram, mas nao cifram.
 * O SunPKCS11 do Java 11 descarta por inteiro um mecanismo informado assim
 * (JDK-8176837), e a assinatura cai no BouncyCastle, que nao usa a chave do
 * token: "Supplied key (...P11PrivateKey) is not a RSAPrivateKey instance".
 *
 * Esta biblioteca carrega o OpenSC e repassa tudo a ele; so acrescenta
 * CKF_ENCRYPT, em C_GetMechanismInfo, aos mecanismos que decifram.
 *
 * Compilar: cc -shared -fPIC -o opensc-java.so opensc-java.c
 * Licenca: CC0.
 */
#include <dlfcn.h>
#include <stddef.h>

#ifndef OPENSC
#define OPENSC "/usr/local/lib/pkcs11/opensc-pkcs11.so"
#endif

#define CKR_OK			0UL
#define CKR_GENERAL_ERROR	5UL
#define CKR_ARGUMENTS_BAD	7UL
#define CKF_ENCRYPT		0x100UL
#define CKF_DECRYPT		0x200UL
#define N_FUNCOES		68	/* PKCS#11 2.x */
#define GET_MECHANISM_INFO	8

struct lista {
	unsigned char versao[2];
	void *f[N_FUNCOES];
};

struct mecanismo {
	unsigned long min, max, flags;
};

typedef unsigned long (*get_mechanism_info)(unsigned long, unsigned long,
    struct mecanismo *);

static struct lista minha;
static get_mechanism_info original;

static unsigned long
mechanism_info(unsigned long slot, unsigned long tipo, struct mecanismo *info)
{
	unsigned long r = original(slot, tipo, info);

	if (r == CKR_OK && info != NULL && (info->flags & CKF_DECRYPT))
		info->flags |= CKF_ENCRYPT;
	return r;
}

unsigned long
C_GetFunctionList(struct lista **saida)
{
	static void *lib;
	unsigned long (*real)(struct lista **);
	struct lista *dele;
	unsigned long r;

	if (saida == NULL)
		return CKR_ARGUMENTS_BAD;
	if (original == NULL) {
		if (lib == NULL)
			lib = dlopen(OPENSC, RTLD_NOW | RTLD_LOCAL);
		if (lib == NULL)
			return CKR_GENERAL_ERROR;
		real = (unsigned long (*)(struct lista **))dlsym(lib,
		    "C_GetFunctionList");
		if (real == NULL)
			return CKR_GENERAL_ERROR;
		r = real(&dele);
		if (r != CKR_OK)
			return r;
		minha = *dele;
		original = (get_mechanism_info)minha.f[GET_MECHANISM_INFO];
		minha.f[GET_MECHANISM_INFO] = (void *)mechanism_info;
	}
	*saida = &minha;
	return CKR_OK;
}
