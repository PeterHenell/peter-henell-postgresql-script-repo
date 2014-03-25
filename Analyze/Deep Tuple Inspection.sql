with bitmap_infomask(bitmask, description) as (
	select 1 ,  'Has Null attribs' union all
	select 2 ,  'Has variable-width attribs'   union all
	select 4 ,  'Has external stored attribs'   union all
	select 8 ,  'Has object-id field'  	 union all	
	select 16 ,  'Xmax is key-shared locker'   union all
	select 32 ,  't_cid is combo cid'  	 union all	
	select 64 ,  'xmax is exclusive locker'   union all	
	select 128 ,  'xmax, if valid, is only locker' union all
	select 256 ,  't_xmin committed'  union all
	select 512 ,  't_xmin invalid/aborted'  union all
	select 1024 ,  't_xmax committed'    union all
	select 2048 ,  't_xmax invalid/aborted'    union all
	select 4096 ,  't_xmax is a MultiXactId'    union all
	select 8192 ,  'this is UPDATED version of row' union all
	select 16384 ,  'Moved by VACUUM FULL (pre 9.0)'    union all
	select 32768 ,  'Moved by VACUUM FULL (pre 9.0)' --   union all
--	select 65520 ,  'visibility-related bits'  
),
bitmap_infomask2(bitmask, description) as (

	select 2047, '11 bits for number of attributes'    union all /* 11 bits for number of attributes */
	/* bits 0x1800 are available */
	select 8192,'tuple was updated and key cols modified, or tuple deleted'    union all /* tuple was updated and key cols modified, or tuple deleted */
	select 16384,'tuple was HOT-updated'    union all /* tuple was HOT-updated */
	select 32768,'this is heap-only tuple'   --union all /* this is heap-only tuple */
	--select 57344,'visibility-related bits'  /* visibility-related bits */
)
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
	--t_infomask2,				/* number of attributes + various flags */
	--t_infomask,
	mask.description as "flag bits",
	mask2.description as "flag bits2",	
	t_hoff as "Size of header",		/* sizeof header incl. bitmap, padding */
	t_bits as "NULL Bitmap",		/* bitmap of NULLs -- VARIABLE LENGTH */
	t_oid
					

FROM heap_page_items(get_raw_page('customers', 0))
CROSS JOIN LATERAL (
	SELECT string_agg(description, ', ') 
	FROM bitmap_infomask 
	WHERE t_infomask & bitmask > 0
) mask (description)
CROSS JOIN LATERAL (
	SELECT string_agg(description, ', ') 
	FROM bitmap_infomask2 
	WHERE t_infomask2 & bitmask > 0
) mask2 (description)


