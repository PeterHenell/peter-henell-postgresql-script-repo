create table t1 ( a int );
insert into t1 (a) values (1);
insert into t1 (a) values (2);
insert into t1 (a) values (3);

create extension pageinspect;

select lp, lp_len, t_xmin
     , t_xmax, lp_off, t_ctid 
                                    --tableName
                                          -- Page#
  from heap_page_items(get_raw_page('t1', 0));

  update t1 set a=4 where a=1;


  select lp, lp_len, t_xmin
     , t_xmax, lp_off, t_ctid 
                                    --tableName
                                          -- Page#
  from heap_page_items(get_raw_page('t1', 0));

  vacuum verbose t1;

  select lp, lp_len, t_xmin
     , t_xmax, lp_off, t_ctid 
                                    --tableName
                                          -- Page#
  from heap_page_items(get_raw_page('t1', 0));


vacuum full verbose t1;

  select lp, lp_len, t_xmin
     , t_xmax, lp_off, t_ctid 
                                    --tableName
                                          -- Page#
  from heap_page_items(get_raw_page('t1', 0));


 SELECT * FROM heap_page_items(get_raw_page('t1', 0));
 SELECT * FROM page_header(get_raw_page('t1', 0));

select
	lp as "Item Pointer",
	lp_off as "Offset to tuple",            /* offset to tuple (from start of page) */
	case lp_flags
		when 0 then 'unused, available for immediate re-use'            /* unused (should always have lp_len=0) */
		when 1 then 'used'              /* used (should always have lp_len>0) */
		when 2 then 'HOT redirect'      /* HOT redirect (should have lp_len=0) */ 
		when 3 then 'dead'              /* dead, may or may not have storage */
	end as "State of Item Pointer",         /* state of item pointer, see below */
 
	lp_len as "Tuple Byte Length",          /* byte length of tuple */

	t_xmin as "Inserting XID",   		/* inserting xact ID */
	t_xmax as "Deleting XID",   		/* deleting or locking xact ID */
	t_field3 as "Union of ", 		/* union  CommandId t_cid;  inserting or deleting command ID, or both. TransactionId t_xvac;   old-style VACUUM FULL xact ID */
	t_ctid ,				/* current TID of this or newer tuple */
	t_infomask2,				/* number of attributes + various flags */
	case t_infomask				/* various flag bits, see below */		
        	when "\0001" then 'Has Null attribs'			/* has null attribute(s) */
       -- 	when 0x0002 then 'Has variable-width attribs'  		/* has variable-width attribute(s) */
       -- 	when 0x0004 then 'Has external stored attribs'  	/* has external stored attribute(s) */
       -- 	when 0x0008 then 'Has object-id field'  		/* has an object-id field */
--		when 0x0010 then 'Xmax is key-shared locker'  		/* xmax is a key-shared locker */
 --       	when 0x0020 then 't_cid is combo cid'  			/* t_cid is a combo cid */
   --     	when 0x0040 then 'xmax is exclusive locker'  		/* xmax is exclusive locker */
     --   	when 0x0080 then 'xmax, if valid, is only locker'  	/* xmax, if valid, is only a locker */
       -- 	when 0x0100 then 't_xmin committed' /* t_xmin committed */
        --	when 0x0200 then 't_xmin invalid/aborted'   /* t_xmin invalid/aborted */
        --	when 0x0400 then 't_xmax committed'   /* t_xmax committed */
        --	when 0x0800 then 't_xmax invalid/aborted'   /* t_xmax invalid/aborted */
        --	when 0x1000 then 't_xmax is a MultiXactId'   /* t_xmax is a MultiXactId */
        --	when 0x2000 then 'this is UPDATEd version of row'   /* this is UPDATEd version of row */
        --	when 0x4000 then 'moved'   /* moved to another place by pre-9.0 VACUUM FULL; kept for binary upgrade support */
	--	when 0x8000 then 'moved'   /* moved from another place by pre-9.0 VACUUM FULL; kept for binary upgrade support */
	--	when 0xFFF0 then 'visibility-related bits'  /* visibility-related bits */

        end as "flag bits",

		
	t_hoff as "Size of header",		/* sizeof header incl. bitmap, padding */
	t_bits as "NULL Bitmap",		/* bitmap of NULLs -- VARIABLE LENGTH */
	t_oid
					

FROM heap_page_items(get_raw_page('t1', 0));


struct HeapTupleHeaderData
{
        union
        {
                HeapTupleFields t_heap;
                DatumTupleFields t_datum;
        }                       t_choice;

        ItemPointerData t_ctid;         /* current TID of this or newer tuple */

        /* Fields below here must match MinimalTupleData! */

        uint16          t_infomask2;    /* number of attributes + various flags */

        uint16          t_infomask;             /* various flag bits, see below */

        uint8           t_hoff;                 /* sizeof header incl. bitmap, padding */

        /* ^ - 23 bytes - ^ */

        bits8           t_bits[1];              /* bitmap of NULLs -- VARIABLE LENGTH */

        /* MORE DATA FOLLOWS AT END OF STRUCT */
};


/*
 * lp_flags has these possible states.  An UNUSED line pointer is available
 * for immediate re-use, the other states are not.
 */
#define LP_UNUSED               0               /* unused (should always have lp_len=0) */
#define LP_NORMAL               1               /* used (should always have lp_len>0) */
#define LP_REDIRECT             2               /* HOT redirect (should have lp_len=0) */
#define LP_DEAD                 3               /* dead, may or may not have storage */


/*
 * information stored in t_infomask:
 */
#define HEAP_HASNULL                    0x0001  /* has null attribute(s) */
#define HEAP_HASVARWIDTH                0x0002  /* has variable-width attribute(s) */
#define HEAP_HASEXTERNAL                0x0004  /* has external stored attribute(s) */
#define HEAP_HASOID                             0x0008  /* has an object-id field */
#define HEAP_XMAX_KEYSHR_LOCK   0x0010  /* xmax is a key-shared locker */
#define HEAP_COMBOCID                   0x0020  /* t_cid is a combo cid */
#define HEAP_XMAX_EXCL_LOCK             0x0040  /* xmax is exclusive locker */
#define HEAP_XMAX_LOCK_ONLY             0x0080  /* xmax, if valid, is only a locker */

 /* xmax is a shared locker */
#define HEAP_XMAX_SHR_LOCK      (HEAP_XMAX_EXCL_LOCK | HEAP_XMAX_KEYSHR_LOCK)

#define HEAP_LOCK_MASK  (HEAP_XMAX_SHR_LOCK | HEAP_XMAX_EXCL_LOCK | \
                                                 HEAP_XMAX_KEYSHR_LOCK)
#define HEAP_XMIN_COMMITTED             0x0100  /* t_xmin committed */
#define HEAP_XMIN_INVALID               0x0200  /* t_xmin invalid/aborted */
#define HEAP_XMAX_COMMITTED             0x0400  /* t_xmax committed */
#define HEAP_XMAX_INVALID               0x0800  /* t_xmax invalid/aborted */
#define HEAP_XMAX_IS_MULTI              0x1000  /* t_xmax is a MultiXactId */
#define HEAP_UPDATED                    0x2000  /* this is UPDATEd version of row */
#define HEAP_MOVED_OFF                  0x4000  /* moved to another place by pre-9.0
                                                                                 * VACUUM FULL; kept for binary
                                                                                 * upgrade support */
#define HEAP_MOVED_IN                   0x8000  /* moved from another place by pre-9.0
                                                                                 * VACUUM FULL; kept for binary
                                                                                 * upgrade support */
#define HEAP_MOVED (HEAP_MOVED_OFF | HEAP_MOVED_IN)

#define HEAP_XACT_MASK                  0xFFF0  /* visibility-related bits */



 /* The overall structure of a heap tuple looks like:
 *                      fixed fields (HeapTupleHeaderData struct)
 *                      nulls bitmap (if HEAP_HASNULL is set in t_infomask)
 *                      alignment padding (as needed to make user data MAXALIGN'd)
 *                      object ID (if HEAP_HASOID is set in t_infomask)
 *                      user data fields
*/

