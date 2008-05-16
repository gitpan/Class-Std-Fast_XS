/*
 * This file is based on Class::XSAccessor
 * by Steffen Müller, Copyright (C) 2008 by Steffen Mueller
 *
 * Copyright (C) 2008 Martin Kutter
 *
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "AutoXS.h"

HV * global_hash_ref;

void init(SV* data_hash_ref) {
    global_hash_ref = (HV*)SvRV(data_hash_ref);
}

MODULE = Class::Std::Fast_XS      PACKAGE = Class::Std::Fast_XS

void init(data_hash_ref)
    SV *    data_hash_ref;

void
getter(self)
        SV* self;
    ALIAS:
    INIT:
        /* Get the const hash key struct from the global storage */
        /* ix is the magic integer variable that is set by the perl guts for us.
         * We uses it to identify the currently running alias of the accessor. Gollum! */
        const autoxs_hashkey readfrom = AutoXS_hashkeys[ix];
        HE* he;
        HE* value_ent;
        SV* key;
    PPCODE:
        if (he = hv_fetch_ent(global_hash_ref, readfrom.key, 0, readfrom.hash)) {
            if (value_ent = hv_fetch_ent((HV*)SvRV(HeVAL(he)), SvRV(self), 0, 0)) {
                XPUSHs(HeVAL(value_ent));
            }
            else {
                XSRETURN_UNDEF;
            }
        }
        else {
            XSRETURN_UNDEF;
        }



void
setter(self, newvalue)
    SV* self;
    SV* newvalue;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = AutoXS_hashkeys[ix];
    HE* he;
    SV* key;

    PPCODE:
    SvREFCNT_inc(newvalue);
    if (he = hv_fetch_ent(global_hash_ref, readfrom.key, 0, readfrom.hash)) {
        key = SvRV(self);
        if (NULL == hv_store_ent((HV*)SvRV(HeVAL(he)), key, newvalue, 0)) {
          croak("Failed to write new value to hash.");
        }
    }
    XPUSHs(self);


void
newxs_getter(name, key)
  char* name;
  char* key;
  PPCODE:
    char* file = __FILE__;
    const unsigned int functionIndex = get_next_hashkey();
    {
      CV * cv;
      unsigned int len;
      autoxs_hashkey hashkey;
      /* This code is very similar to what you get from using the ALIAS XS syntax.
       * Except I took it from the generated C code. Hic sunt dragones, I suppose... */
      cv = newXS(name, XS_Class__Std__Fast_XS_getter, file);
      if (cv == NULL)
        croak("ARG! SOMETHING WENT REALLY WRONG!");
      XSANY.any_i32 = functionIndex;

      /* Precompute the hash of the key and store it in the global structure */
      len = strlen(key);
      hashkey.key = newSVpvn(key, len);
      PERL_HASH(hashkey.hash, key, len);
      AutoXS_hashkeys[functionIndex] = hashkey;
    }


void
newxs_setter(name, key)
  char* name;
  char* key;
  PPCODE:
    char* file = __FILE__;
    const unsigned int functionIndex = get_next_hashkey();
    {
      CV * cv;
      unsigned int len;
      autoxs_hashkey hashkey;
      /* This code is very similar to what you get from using the ALIAS XS syntax.
       * Except I took it from the generated C code. Hic sunt dragones, I suppose... */
      cv = newXS(name, XS_Class__Std__Fast_XS_setter, file);
      if (cv == NULL)
        croak("ARG! SOMETHING WENT REALLY WRONG!");
      XSANY.any_i32 = functionIndex;

      /* Precompute the hash of the key and store it in the global structure */
      len = strlen(key);
      hashkey.key = newSVpvn(key, len);
      PERL_HASH(hashkey.hash, key, len);
      AutoXS_hashkeys[functionIndex] = hashkey;
    }

