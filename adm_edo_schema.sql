--
-- PostgreSQL database dump
--

\restrict 3iT9kp4JV4M2GMZlWRtz7NUhQmj8N6uBruVP3l59v2PkBKc9tMFC1BTl3n60cJi

-- Dumped from database version 16.3 (Ubuntu 16.3-1.pgdg22.04+1)
-- Dumped by pg_dump version 16.13 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: archive; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA archive;


--
-- Name: president_assignments; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA president_assignments;


--
-- Name: uzcrypto; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA uzcrypto;


--
-- Name: workflow; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA workflow;


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: ltree; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA public;


--
-- Name: EXTENSION ltree; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION ltree IS 'data type for hierarchical tree-like structures';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: document_secret_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.document_secret_type AS ENUM (
    'NOT_ANNOUNCED',
    'SECRET',
    'SIMPLE',
    'XDFU'
);


--
-- Name: initiative_doc_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.initiative_doc_status AS ENUM (
    'new',
    'sent',
    'approved',
    'rejected',
    'kpi_records_inserted',
    'kpi_records_finalized'
);


--
-- Name: key_algorithm; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.key_algorithm AS ENUM (
    'uzdst1',
    'uzdst2',
    'rsa',
    'ecdsa'
);


--
-- Name: key_algorithm_version; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.key_algorithm_version AS ENUM (
    '1.2.860.3.15.1.1.1',
    '1.2.860.3.15.1.1.2.1',
    '1.2.840.113549.1.1.1',
    '1.2.840.10045.2.1'
);


--
-- Name: meth; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.meth AS ENUM (
    'set_key',
    'create_pkcs10'
);


--
-- Name: nhh_agreement_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.nhh_agreement_status AS ENUM (
    'disagree',
    'agree'
);


--
-- Name: nhh_agreement_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.nhh_agreement_type AS ENUM (
    'internal',
    'external'
);


--
-- Name: nhh_kpi_score_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.nhh_kpi_score_type AS ENUM (
    'point',
    'coefficient'
);


--
-- Name: nhh_kpi_selection_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.nhh_kpi_selection_type AS ENUM (
    'single',
    'multi'
);


--
-- Name: nhh_kpi_version_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.nhh_kpi_version_status AS ENUM (
    'outdated',
    'active',
    'upcoming'
);


--
-- Name: suggestion_category; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.suggestion_category AS ENUM (
    'FEATURE_REQUEST',
    'BUG_REPORT',
    'IMPROVEMENT'
);


--
-- Name: suggestion_priority; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.suggestion_priority AS ENUM (
    'LOW',
    'MEDIUM',
    'HIGH'
);


--
-- Name: suggestion_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.suggestion_status AS ENUM (
    'PENDING',
    'APPROVED',
    'DONE',
    'ACCEPTED',
    'REJECTED'
);


--
-- Name: type_of_content_template; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.type_of_content_template AS ENUM (
    'task',
    'sign'
);


--
-- Name: gen_task_code(); Type: FUNCTION; Schema: president_assignments; Owner: -
--

CREATE FUNCTION president_assignments.gen_task_code() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    code              varchar;
    code_str          varchar;
    code_number       varchar;
    code_task         varchar;
    str_black_list    varchar[] = ARRAY ['XUY','SEX','KOT','LOX']:: varchar[];
    number_black_list varchar[] = ARRAY ['1111','2222','3333','4444','5555','6666','7777','8888','9999','0000']:: varchar[];
    black_str boolean;
    black_num boolean;
BEGIN
    code_str = array_to_string(
            ARRAY(
                    SELECT chr((65 + round(random() * 25)) :: integer) FROM generate_series(1, 3)), '');
    code_number = array_to_string(
            ARRAY(
                    SELECT chr((48 + round(random() * 9)) :: integer) FROM generate_series(1, 4)), '');
    black_str  = exists(select * from unnest(str_black_list) s where s = code_str);
    black_num  = exists(select * from unnest(number_black_list) s where s = code_number);
    IF (
            black_str or
            black_num
        ) THEN
        return president_assignments.gen_task_code();
    END IF;
    code = concat(code_str, code_number);
    code_task = (select id from president_assignments.tasks t where t.task_code = code::varchar);
    IF (code_task is not null) THEN
        return president_assignments.gen_task_code();
    END IF;
    return code;
END;
$$;


--
-- Name: row_updated(); Type: FUNCTION; Schema: president_assignments; Owner: -
--

CREATE FUNCTION president_assignments.row_updated() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF current_query() LIKE '%#@_UPDATE_TIME_TRIGGER_OFF_@#%' THEN RETURN new; END IF;

	BEGIN
		new.updated_time = EXTRACT(EPOCH FROM clock_timestamp()) * 1000000;
    EXCEPTION WHEN undefined_column THEN
        RAISE NOTICE 'Not exists column "updated_time" on the table: "%"', tg_table_name;
    END;

	RETURN new;
END;
$$;


--
-- Name: send_task_set_inactive(); Type: FUNCTION; Schema: president_assignments; Owner: -
--

CREATE FUNCTION president_assignments.send_task_set_inactive() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    update president_assignments.task_send set active = 0 where task_id  = new.task_id
                                                                and recipient_id = new.recipient_id
                                                                and document_id = new.document_id;

           RETURN new;
END;
$$;


--
-- Name: set_document_year_by_document_id(); Type: FUNCTION; Schema: president_assignments; Owner: -
--

CREATE FUNCTION president_assignments.set_document_year_by_document_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    new.document_year := date_part('year', public.extractmongotimestamp(new.document_id)::date);
    return new;
end;
$$;


--
-- Name: set_year_by_id(); Type: FUNCTION; Schema: president_assignments; Owner: -
--

CREATE FUNCTION president_assignments.set_year_by_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    new.year := date_part('year', new.document_date::date);
    return new;
end;
$$;


--
-- Name: create_department_structure_hierarchy(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_department_structure_hierarchy(parent_id character varying) RETURNS public.ltree
    LANGUAGE sql IMMUTABLE
    AS $_$
                SELECT coalesce(g.parent_hierarchy,'') || g.id
                FROM department_structure g
                WHERE g.id = $1 AND g.is_deleted IS NOT TRUE
                $_$;


--
-- Name: create_document_hierarchy(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_document_hierarchy(parent_id character varying) RETURNS public.ltree
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT coalesce(doc.parent_hierarchy,'') || doc.id
    FROM documents doc
    WHERE doc.id = $1 AND doc.is_deleted IS NOT TRUE
    $_$;


--
-- Name: create_duty_schedule_group_hierarchy(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_duty_schedule_group_hierarchy(parent_id character varying) RETURNS public.ltree
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT coalesce(g.parent_hierarchy,'') || g.id
    FROM duty_schedule_group g
    WHERE g.id = $1 AND g.is_deleted IS NOT TRUE
    $_$;


--
-- Name: create_organizational_structure_hierarchy(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_organizational_structure_hierarchy(parent_id character varying) RETURNS public.ltree
    LANGUAGE sql IMMUTABLE
    AS $_$
                SELECT coalesce(g.parent_hierarchy,'') || g.id
                FROM organizational_structure g
                WHERE g.id = $1 AND g.is_deleted IS NOT TRUE
                $_$;


--
-- Name: create_recipient_hierarchy(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_recipient_hierarchy(parent_id character varying) RETURNS public.ltree
    LANGUAGE sql IMMUTABLE
    AS $_$
select coalesce(recipient.parent_hierarchy,'') || recipient.id
from  task_recipients recipient
where recipient.id = $1 and recipient.is_deleted is not true
$_$;


--
-- Name: create_task_hierarchy(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.create_task_hierarchy(parent_id character varying) RETURNS public.ltree
    LANGUAGE sql IMMUTABLE
    AS $_$
select coalesce(task.parent_hierarchy,'') || task.id
from tasks task
where task.id = $1 and task.is_deleted is not true
$_$;


--
-- Name: extractmongotimestamp(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.extractmongotimestamp(text) RETURNS timestamp with time zone
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT TO_TIMESTAMP(int_val) ts_val
FROM (
    SELECT ('x' || lpad(left(objectid,8), 8, '0'))::bit(32)::int AS int_val
    FROM   (
       VALUES ($1)
       ) AS t1(objectid)
    ) AS t2$_$;


--
-- Name: fn_reparent_unit(character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_reparent_unit(p_unit_id character varying, p_new_parent character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_old_path ltree;
    v_new_path ltree;
    v_new_depth INT;
BEGIN
    SELECT parent_hierarchy INTO v_old_path
    FROM structural_units WHERE id = p_unit_id AND is_deleted = FALSE;

    IF v_old_path IS NULL THEN
        RAISE EXCEPTION 'Unit % not found', p_unit_id;
    END IF;

    IF p_new_parent IS NULL THEN
        v_new_path := p_unit_id::text::ltree;
        v_new_depth := 0;
    ELSE
        SELECT parent_hierarchy || p_unit_id::text::ltree, depth + 1
        INTO v_new_path, v_new_depth
        FROM structural_units
        WHERE id = p_new_parent AND is_deleted = FALSE;

        IF v_new_path IS NULL THEN
            RAISE EXCEPTION 'New parent % not found', p_new_parent;
        END IF;

        IF v_new_path <@ v_old_path THEN
            RAISE EXCEPTION 'Cannot move unit under its own descendant';
        END IF;
    END IF;

    UPDATE structural_units
    SET parent_hierarchy = v_new_path || subpath(parent_hierarchy, nlevel(v_old_path)),
        depth = v_new_depth + (nlevel(parent_hierarchy) - nlevel(v_old_path)),
        parent_id = CASE WHEN id = p_unit_id THEN p_new_parent ELSE parent_id END,
        updated_at = CURRENT_TIMESTAMP
    WHERE parent_hierarchy <@ v_old_path
      AND is_deleted = FALSE;
END;
$$;


--
-- Name: fn_set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at := CURRENT_TIMESTAMP;
    IF TG_TABLE_NAME = 'structural_units' THEN
        NEW.updated_time := (EXTRACT(epoch FROM clock_timestamp()) * 1000000)::bigint;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: fn_su_set_path(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_su_set_path() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.parent_id IS NULL THEN
        NEW.parent_hierarchy := NEW.id::text::ltree;
        NEW.depth := 0;
    ELSE
        SELECT parent_hierarchy, depth + 1
        INTO NEW.parent_hierarchy, NEW.depth
        FROM structural_units
        WHERE id = NEW.parent_id AND is_deleted = FALSE;

        IF NEW.parent_hierarchy IS NULL THEN
            RAISE EXCEPTION 'Parent unit % not found or deleted', NEW.parent_id;
        END IF;

        NEW.parent_hierarchy := NEW.parent_hierarchy || NEW.id::text::ltree;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: fn_sync_sp_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_sync_sp_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_has_primary BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM assignments
        WHERE staffing_position_id = COALESCE(NEW.staffing_position_id, OLD.staffing_position_id)
          AND is_reserve = FALSE
          AND ended_at IS NULL
          AND is_deleted = FALSE
    ) INTO v_has_primary;

    UPDATE staffing_positions
    SET status = CASE WHEN v_has_primary THEN 2 ELSE 1 END,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = COALESCE(NEW.staffing_position_id, OLD.staffing_position_id);

    RETURN COALESCE(NEW, OLD);
END;
$$;


--
-- Name: gen_async_processor_code(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gen_async_processor_code() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
    DECLARE
        gen_code              varchar;
        code_str          varchar;
        code_number       varchar;
        code_doc          varchar;
        str_black_list    varchar[] = ARRAY ['OM','SEX','KOT','LOX']::varchar[];
        number_black_list varchar[] = ARRAY ['1111','2222','3333','4444','5555','6666','7777','8888','9999','0000']::varchar[];
        black_str boolean;
        black_num boolean;
    BEGIN
        code_str = array_to_string(
                ARRAY(
                        SELECT chr((65 + round(random() * 25)) :: integer) FROM generate_series(1, 3)), '');
        code_number = array_to_string(
                ARRAY(
                        SELECT chr((48 + round(random() * 9)) :: integer) FROM generate_series(1, 4)), '');
        black_str  = exists(select * from unnest(str_black_list) s where s = code_str);
        black_num  = exists(select * from unnest(number_black_list) s where s = code_number);
        IF (
                black_str or
                black_num
            ) THEN
            return gen_document_number();
        END IF;
        gen_code = concat(code_str, code_number);
        code_doc = (select id from async_processor where code = gen_code::varchar);
        IF (code_doc is not null) THEN
            return gen_document_number();
        END IF;
        return gen_code;
    END;
    $$;


--
-- Name: gen_document_number(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.gen_document_number() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
    DECLARE
        code              varchar;
        code_str          varchar;
        code_number       varchar;
        code_doc          varchar;
        str_black_list    varchar[] = ARRAY ['OM','SEX','KOT','LOX']::varchar[];
        number_black_list varchar[] = ARRAY ['1111','2222','3333','4444','5555','6666','7777','8888','9999','0000']::varchar[];
        black_str boolean;
        black_num boolean;
    BEGIN
        code_str = array_to_string(
                ARRAY(
                        SELECT chr((65 + round(random() * 25)) :: integer) FROM generate_series(1, 2)), '');
        code_number = array_to_string(
                ARRAY(
                        SELECT chr((48 + round(random() * 9)) :: integer) FROM generate_series(1, 8)), '');
        black_str  = exists(select * from unnest(str_black_list) s where s = code_str);
        black_num  = exists(select * from unnest(number_black_list) s where s = code_number);
        IF (
                black_str or
                black_num
            ) THEN
            return gen_document_number();
        END IF;
        code = concat(code_str, code_number);
        code_doc = (select id from documents where document_number = code::varchar);
        IF (code_doc is not null) THEN
            return gen_document_number();
        END IF;
        return code;
    END;
    $$;


--
-- Name: generate_jwt(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_jwt(p_user_id uuid, p_secret text) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
DECLARE
    header_json  jsonb := '{"alg": "HS256", "typ": "JWT"}';
    payload_json jsonb;
    header_base64 text;
    payload_base64 text;
    signature_base64 text;
    unsigned_token text;
    signed_token text;
BEGIN
    -- Select user data
    SELECT jsonb_build_object(
        'id', u.id,
        'db_id', u.db_id,
        'username', u.username,
        'middle_name', u.middle_name,
        'last_name', u.last_name,
        'is_deleted', u.is_deleted,
        'created_at', u.created_at,
        'first_name', u.first_name,
        'verified', u.verified,
        'full_name', u.full_name,
        'region_id', org.region_id,
        'district_id', org.district_id,
        'sequence_index', u.sequence_index,
        'department_id', u.department_id,
        'block_id', u.block_id,
        'must_change_password', u.must_change_password,
        'personal_code', u.personal_code,
        'pinpp', u.pinpp
    )
    INTO payload_json
    FROM users u
    JOIN organizations org
        ON org.id = u.db_id
       AND (org.is_deleted IS NOT TRUE)
    WHERE u.id = p_user_id
      AND u.is_active = true
      AND u.is_deleted = false
    GROUP BY u.id, org.id;

    IF payload_json IS NULL THEN
        RAISE EXCEPTION 'User with id % not found or inactive', p_user_id;
    END IF;

    payload_json := jsonb_set(payload_json, '{iat}', to_jsonb(floor(EXTRACT(EPOCH FROM now()))::int));
    payload_json := jsonb_set(payload_json, '{exp}', to_jsonb(floor(EXTRACT(EPOCH FROM now() + interval '7 days'))::int));

    header_base64 := replace(replace(encode(convert_to(header_json::text, 'UTF8'), 'base64'), '+', '-'), '/', '_');
    header_base64 := regexp_replace(header_base64, '=+$', '');

    payload_base64 := replace(replace(encode(convert_to(payload_json::text, 'UTF8'), 'base64'), '+', '-'), '/', '_');
    payload_base64 := regexp_replace(payload_base64, '=+$', '');

    unsigned_token := header_base64 || '.' || payload_base64;

    signature_base64 := encode(hmac(convert_to(unsigned_token, 'UTF8'), convert_to(p_secret, 'UTF8'), 'sha256'), 'base64');
    signature_base64 := replace(replace(signature_base64, '+', '-'), '/', '_');
    signature_base64 := regexp_replace(signature_base64, '=+$', '');

    signed_token := unsigned_token || '.' || signature_base64;

    -- Remove all line breaks (just in case)
    signed_token := regexp_replace(signed_token, '[\n\r\s]+', '', 'g');

    RETURN signed_token;
END;
$_$;


--
-- Name: generate_jwt(character varying, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_jwt(p_user_id character varying, p_secret text) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
DECLARE
    header_json  jsonb := '{"alg": "HS256", "typ": "JWT"}';
    payload_json jsonb;
    header_base64 text;
    payload_base64 text;
    signature_base64 text;
    unsigned_token text;
    signed_token text;
BEGIN
    -- 1. Select same user fields
    SELECT jsonb_build_object(
        'id', u.id,
        'db_id', u.db_id,
        'username', u.username,
        'middle_name', u.middle_name,
        'last_name', u.last_name,
        'is_deleted', u.is_deleted,
        'created_at', u.created_at,
        'first_name', u.first_name,
        'verified', u.verified,
        'full_name', u.full_name,
        'region_id', org.region_id,
        'district_id', org.district_id,
        'sequence_index', u.sequence_index,
        'department_id', u.department_id,
        'block_id', u.block_id,
        'must_change_password', u.must_change_password,
        'personal_code', u.personal_code,
        'pinpp', u.pinpp
    )
    INTO payload_json
    FROM users u
    JOIN organizations org
        ON org.id = u.db_id
       AND (org.is_deleted IS NOT TRUE)
    WHERE u.id = p_user_id
      AND u.is_active = true
      AND u.is_deleted = false
    GROUP BY u.id, org.id;

    IF payload_json IS NULL THEN
        RAISE EXCEPTION 'User with id % not found or inactive', p_user_id;
    END IF;

    -- 2. Add iat/exp claims
    payload_json := jsonb_set(payload_json, '{iat}', to_jsonb(floor(EXTRACT(EPOCH FROM now()))::int));
    payload_json := jsonb_set(payload_json, '{exp}', to_jsonb(floor(EXTRACT(EPOCH FROM now() + interval '7 days'))::int));

    -- 3. Encode header and payload (Base64URL without '=')
    header_base64 := replace(replace(encode(convert_to(header_json::text, 'UTF8'), 'base64'), '+', '-'), '/', '_');
    header_base64 := regexp_replace(header_base64, '=+$', '');

    payload_base64 := replace(replace(encode(convert_to(payload_json::text, 'UTF8'), 'base64'), '+', '-'), '/', '_');
    payload_base64 := regexp_replace(payload_base64, '=+$', '');

    unsigned_token := header_base64 || '.' || payload_base64;

    -- 4. Sign exactly like jsonwebtoken does (UTF8 HMAC-SHA256)
    signature_base64 := encode(hmac(convert_to(unsigned_token, 'UTF8'), convert_to(p_secret, 'UTF8'), 'sha256'), 'base64');
    signature_base64 := replace(replace(signature_base64, '+', '-'), '/', '_');
    signature_base64 := regexp_replace(signature_base64, '=+$', '');

    signed_token := unsigned_token || '.' || signature_base64;

    RETURN signed_token;
END;
$_$;


--
-- Name: generate_jwt_debug(character varying, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_jwt_debug(p_user_id character varying, p_secret text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
DECLARE
    header_json  jsonb;
    payload_json jsonb;
    header_b64 text;
    payload_b64 text;
    unsigned_token text;
    signature_b64url text;
    signature_hex text;
BEGIN
    -- Build compact header (jsonb text is compact)
    header_json := jsonb_build_object('alg','HS256','typ','JWT');

    -- Select payload exactly like your Knex select (same column names)
    SELECT jsonb_build_object(
        'id', u.id,
        'db_id', u.db_id,
        'username', u.username,
        'middle_name', u.middle_name,
        'last_name', u.last_name,
        'is_deleted', u.is_deleted,
        'created_at', u.created_at,
        'first_name', u.first_name,
        'verified', u.verified,
        'full_name', u.full_name,
        'region_id', org.region_id,
        'district_id', org.district_id,
        'sequence_index', u.sequence_index,
        'department_id', u.department_id,
        'block_id', u.block_id,
        'must_change_password', u.must_change_password,
        'personal_code', u.personal_code,
        'pinpp', u.pinpp
    )
    INTO payload_json
    FROM users u
    JOIN organizations org
      ON org.id = u.db_id
     AND (org.is_deleted IS NOT TRUE)
    WHERE u.id = p_user_id
      AND u.is_active = true
      AND u.is_deleted = false
    GROUP BY u.id, org.id;

    IF payload_json IS NULL THEN
        RAISE EXCEPTION 'User with id % not found or inactive', p_user_id;
    END IF;

    -- Add iat and exp as integers (epoch seconds)
    payload_json := jsonb_set(payload_json, '{iat}', to_jsonb(floor(EXTRACT(EPOCH FROM now()))::int));
    payload_json := jsonb_set(payload_json, '{exp}', to_jsonb(floor(EXTRACT(EPOCH FROM now() + interval '7 days'))::int));

    -- Base64URL encode header & payload (no padding)
    header_b64 := replace(replace(encode(convert_to(header_json::text, 'UTF8'), 'base64'), '+', '-'), '/', '_');
    header_b64 := regexp_replace(header_b64, '=+$', '');

    payload_b64 := replace(replace(encode(convert_to(payload_json::text, 'UTF8'), 'base64'), '+', '-'), '/', '_');
    payload_b64 := regexp_replace(payload_b64, '=+$', '');

    unsigned_token := header_b64 || '.' || payload_b64;

    -- Compute HMAC-SHA256 over exact UTF8 bytes (produce hex and base64url)
    signature_hex := encode(hmac(convert_to(unsigned_token, 'UTF8'), convert_to(p_secret, 'UTF8'), 'sha256'), 'hex');

    signature_b64url := encode(hmac(convert_to(unsigned_token, 'UTF8'), convert_to(p_secret, 'UTF8'), 'sha256'), 'base64');
    signature_b64url := replace(replace(signature_b64url, '+', '-'), '/', '_');
    signature_b64url := regexp_replace(signature_b64url, '=+$', '');

    -- Final token
    RETURN jsonb_build_object(
      'token', unsigned_token || '.' || signature_b64url,
      'unsigned', unsigned_token,
      'signature_hex', signature_hex
    );
END;
$_$;


--
-- Name: generate_object_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_object_id() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
    DECLARE
        time_component bigint;
        machine_id     bigint := FLOOR(random() * 16777215);
        process_id     bigint;
        seq_id         bigint := FLOOR(random() * 16777215);
        result         varchar := '';
    BEGIN
        SELECT FLOOR(EXTRACT(EPOCH FROM clock_timestamp())) INTO time_component;
        SELECT pg_backend_pid() INTO process_id;

        result := result || lpad(to_hex(time_component), 8, '0');
        result := result || lpad(to_hex(machine_id), 6, '0');
        result := result || lpad(to_hex(process_id), 4, '0');
        result := result || lpad(to_hex(seq_id), 6, '0');
        RETURN result;
    END;
    $$;


--
-- Name: generate_user_jwt(character varying, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_user_jwt(p_user_id character varying, p_jwt_secret text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_user jsonb;
    v_header jsonb := '{"alg": "HS256", "typ": "JWT"}'::jsonb;
    v_header_b64 text;
    v_payload_b64 text;
    v_signature text;
    v_token text;
BEGIN
    -- 1️⃣ Select user data as JSON
    SELECT jsonb_build_object(
        'id', u.id,
        'db_id', u.db_id,
        'username', u.username,
        'middle_name', u.middle_name,
        'last_name', u.last_name,
        'is_deleted', u.is_deleted,
        'created_at', u.created_at,
        'first_name', u.first_name,
        'verified', u.verified,
        'full_name', u.full_name,
        'region_id', org.region_id,
        'district_id', org.district_id,
        'sequence_index', u.sequence_index,
        'department_id', u.department_id,
        'parent_department_id', u.parent_department_id,
        'block_id', u.block_id,
        'must_change_password', u.must_change_password,
        'personal_code', u.personal_code,
        'pinpp', u.pinpp,
        'iat', extract(epoch from now())::bigint,
        'exp', extract(epoch from now() + interval '7 days')::bigint
    )
    INTO v_user
    FROM users u
    JOIN organizations org ON org.id = u.db_id AND org.is_deleted IS NOT TRUE
    WHERE u.id = p_user_id
      AND u.is_active = TRUE
      AND u.is_deleted = FALSE
    GROUP BY u.id, org.id;

    IF v_user IS NULL THEN
        RAISE EXCEPTION 'User not found or inactive' USING ERRCODE = 'P0002';
    END IF;

    -- 2️⃣  Encode header and payload (Base64 URL-safe, no line breaks)
    v_header_b64 := encode(convert_to(v_header::text, 'UTF8'), 'base64');
    v_header_b64 := replace(replace(replace(v_header_b64, '+', '-'), '/', '_'), '=', '');
    v_header_b64 := regexp_replace(v_header_b64, E'[\\n\\r]+', '', 'g');

    v_payload_b64 := encode(convert_to(v_user::text, 'UTF8'), 'base64');
    v_payload_b64 := replace(replace(replace(v_payload_b64, '+', '-'), '/', '_'), '=', '');
    v_payload_b64 := regexp_replace(v_payload_b64, E'[\\n\\r]+', '', 'g');

    -- 3️⃣  Create HMAC SHA256 signature
    v_signature := encode(
        hmac(v_header_b64 || '.' || v_payload_b64, p_jwt_secret, 'sha256'),
        'base64'
    );
    v_signature := replace(replace(replace(v_signature, '+', '-'), '/', '_'), '=', '');
    v_signature := regexp_replace(v_signature, E'[\\n\\r]+', '', 'g');

    -- 4️⃣  Combine into full JWT token (no newlines)
    v_token := v_header_b64 || '.' || v_payload_b64 || '.' || v_signature;
    v_token := regexp_replace(v_token, E'[\\n\\r]+', '', 'g');

    RETURN v_token;
END;
$$;


--
-- Name: generate_watermark_code(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_watermark_code() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Crockford Base32 alphabet (excludes I, L, O, U to avoid confusion)
    alphabet TEXT := '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
    code TEXT := '';
    i INTEGER;
    max_attempts INTEGER := 100;
    attempt INTEGER := 0;
    code_exists BOOLEAN;
BEGIN
    LOOP
        -- Generate new 8-character code
        code := '';
        FOR i IN 1..8 LOOP
            code := code || substr(alphabet, floor(random() * 32 + 1)::int, 1);
        END LOOP;

        -- Check if code already exists
        SELECT EXISTS(
            SELECT 1 FROM watermark_logs WHERE watermark_code = code
        ) INTO code_exists;

        -- If unique, return it
        IF NOT code_exists THEN
            RETURN code;
        END IF;

        -- Increment attempt counter
        attempt := attempt + 1;

        -- Safety check to prevent infinite loop
        IF attempt >= max_attempts THEN
            RAISE EXCEPTION 'Failed to generate unique watermark code after % attempts', max_attempts;
        END IF;
    END LOOP;
END;
$$;


--
-- Name: get_business_trip_stage_order(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_business_trip_stage_order(p_doc_type_code text) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
	RETURN CASE p_doc_type_code
		WHEN 'BUSINESS_TRIP_PLAN'        THEN 1
		WHEN 'BUSINESS_TRIP_NOTICE'      THEN 2
		WHEN 'BUSINESS_TRIP_ORDER'       THEN 3
		WHEN 'BUSINESS_TRIP_CERTIFICATE' THEN 4
		ELSE 0
	END;
END;
$$;


--
-- Name: get_department_by_id_json(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_department_by_id_json(department_id character varying) RETURNS jsonb
    LANGUAGE sql IMMUTABLE
    AS $_$
select jsonb_build_object(
               'id', department.id,
               'name_uz', department.name_uz,
               'name_ru', department.name_ru,
               'name_uz_cryl', department.name_uz_cryl
       )
from departments department
where department.id = $1;
$_$;


--
-- Name: get_department_by_parent_hierarchy(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_department_by_parent_hierarchy(parent_dep_id character varying) RETURNS public.ltree
    LANGUAGE sql IMMUTABLE
    AS $_$
WITH RECURSIVE base_department AS (
            SELECT dep.id,
                   dep.parent_id,
                   dep.name_uz,
                   dep.db_id,
                   1 AS level
            from departments dep
            where dep.id = $1
            UNION
            SELECT dep_parent.id,
                   dep_parent.parent_id,
                   dep_parent.name_uz,
                   dep_parent.db_id,
                   base_department.level + 1 AS level
            from departments dep_parent
                   join base_department on dep_parent.id = base_department.parent_id
          )
          SELECT array_to_string(array_agg(id order by level desc),'.')::ltree
          FROM base_department;
$_$;


--
-- Name: get_file_by_id_json(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_file_by_id_json(file_id character varying) RETURNS jsonb
    LANGUAGE sql IMMUTABLE
    AS $_$
      select jsonb_build_object(
        'id', file.id,
        'name', file.name,
        'size', file.size,
        'type', file.type,
        'hash', file.hash,
        'is_private', file.is_private,
        'info', file.info
      )
      from files file
      where file.id = $1;
    $_$;


--
-- Name: get_parent_hierarchy_of_structure(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_parent_hierarchy_of_structure(parent_dep_id character varying) RETURNS public.ltree
    LANGUAGE sql IMMUTABLE
    AS $_$
WITH RECURSIVE base_department AS (
            SELECT dep.id,
                   dep.parent_id,
                   dep.name,
                   1 AS level
            from department_structure dep
            where dep.id = $1
            UNION
            SELECT dep_parent.id,
                   dep_parent.parent_id,
                   dep_parent.name,
                   base_department.level + 1 AS level
            from department_structure dep_parent
                   join base_department on dep_parent.id = base_department.parent_id
          )
          SELECT array_to_string(array_agg(id order by level desc),'.')::ltree
          FROM base_department;
$_$;


--
-- Name: get_published_document_group_hierarchy(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_published_document_group_hierarchy(parent_id character varying) RETURNS public.ltree
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT coalesce(published_document_groups.parent_hierarchy,'') || published_document_groups.id
    FROM published_document_groups
    WHERE published_document_groups.id = $1 AND published_document_groups.is_deleted IS NOT TRUE
    $_$;


--
-- Name: get_user_by_id_json(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_user_by_id_json(user_id character varying) RETURNS jsonb
    LANGUAGE sql IMMUTABLE
    AS $_$
select jsonb_build_object(
               'id', u.id,
               'first_name', u.first_name,
               'last_name', u.last_name,
               'middle_name', u.middle_name,
               'db_id', u.db_id,
               'organization', jsonb_build_object('id', org.id, 'name_uz', org.name_uz, 'name_ru', org.name_ru),
               'department', jsonb_build_object('id', d.id, 'name_uz', d.name_uz, 'name_ru', d.name_ru),
               'position', jsonb_build_object('id', p.id, 'name_uz', p.name_uz,'name_ru', p.name_ru),
               'full_name', u.full_name,
               'short_name', short_user_name(u.first_name, u.middle_name, u.last_name)
       )
from public.users u
         left join organizations org on org.id = u.db_id
         left join departments d on d.id = u.department_id
         left join positions p on p.id = u.position_id
where u.id = $1
group by u.id, org.id, p.id, d.id;
$_$;


--
-- Name: replace_org_ids_query(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.replace_org_ids_query() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	ids TEXT = '';
	rec RECORD;
BEGIN
	FOR rec IN
		SELECT
			concat_ws('', '
				UPDATE ', sch.nspname, '.', tbl.relname, ' AS u
				SET ', col.attname, ' = i.edo_id
				FROM organizations_ids AS i
				WHERE u.', col.attname, ' = i.id
					AND i.edo_id > '''';') as upd -- key: fk.conname,
		FROM pg_constraint fk
		JOIN pg_class tbl ON tbl.oid = fk.conrelid
		JOIN pg_namespace sch ON sch.oid = tbl.relnamespace
		JOIN pg_attribute col ON col.attrelid = fk.conrelid AND col.attnum = ANY(fk.conkey)
		WHERE fk.confrelid = 'organizations'::regclass
		  AND fk.contype = 'f'
		ORDER BY sch.nspname, tbl.relname
--		LIMIT 3
	LOOP
		ids = ids || '
			' || rec.upd;
	END LOOP;
    return '			' || ids;
END;
$$;


--
-- Name: revert_business_trip_stage(text, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.revert_business_trip_stage(p_document_id text, p_reverted_by text DEFAULT NULL::text, p_cascade_later_stages boolean DEFAULT true) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_doc RECORD;
	v_doc_type_code TEXT;
	v_target_stage_order INT;
	v_root_id TEXT;
	v_current_id TEXT;
	v_relation RECORD;
	v_sibling RECORD;
	v_sibling_results JSONB := '[]'::JSONB;
	v_single_result JSONB;
	v_target_root_status TEXT;
	v_latest_active_stage_order INT;
	v_result JSONB;
BEGIN
	-- ========================================
	-- 1. Get the target document and its stage
	-- ========================================
	SELECT d.id, d.type_id, d.internal_doc_type_id, d.parent_document_id
	INTO v_doc
	FROM documents d
	WHERE d.id = p_document_id AND d.is_deleted IS NOT TRUE;

	IF v_doc IS NULL THEN
		RAISE EXCEPTION 'Document not found: %', p_document_id;
	END IF;

	-- Get the internal doc type code for this document
	SELECT idt.code INTO v_doc_type_code
	FROM internal_doc_types idt
	WHERE idt.id = v_doc.internal_doc_type_id;

	v_target_stage_order := get_business_trip_stage_order(v_doc_type_code);

	-- ========================================
	-- 2. Find the root PLAN via internal_document_relations
	-- ========================================
	v_current_id := p_document_id;

	FOR i IN 1..10 LOOP
		SELECT * INTO v_relation
		FROM internal_document_relations
		WHERE child_id = v_current_id;

		IF v_relation IS NULL THEN
			EXIT; -- v_current_id IS the root
		END IF;

		v_current_id := v_relation.parent_id;
	END LOOP;

	v_root_id := v_current_id;

	-- ========================================
	-- 3. Revert stages
	-- ========================================
	IF p_cascade_later_stages = TRUE THEN
		-- CASCADE MODE: revert all stages with order >= target (highest first)
		FOR v_sibling IN
			SELECT d.id AS doc_id, idt.code AS type_code,
			       get_business_trip_stage_order(idt.code) AS stage_order,
			       d.parent_document_id
			FROM internal_document_relations idr
			JOIN documents d ON d.id::TEXT = idr.child_id AND d.is_deleted IS NOT TRUE
			JOIN internal_doc_types idt ON idt.id = d.internal_doc_type_id
			WHERE idr.parent_id = v_root_id
			  AND get_business_trip_stage_order(idt.code) >= v_target_stage_order
			ORDER BY get_business_trip_stage_order(idt.code) DESC, d.created_at DESC
		LOOP
			v_single_result := revert_single_stage(
				v_sibling.doc_id,
				p_reverted_by,
				FALSE
			);
			v_sibling_results := v_sibling_results || v_single_result;
		END LOOP;

		-- If the target IS the root PLAN, revert its doc_sends but don't soft-delete
		IF v_root_id = p_document_id THEN
			v_single_result := revert_single_stage(p_document_id, p_reverted_by, TRUE);
			v_sibling_results := v_sibling_results || v_single_result;
		END IF;

		-- Root status: determined by target stage
		v_target_root_status := CASE v_target_stage_order
			WHEN 1 THEN 'ON_REVIEW'       -- Reverting PLAN → before signing
			WHEN 2 THEN 'SIGNED'          -- Reverting NOTICE → PLAN stays SIGNED
			WHEN 3 THEN 'NOTICE_SIGNED'   -- Reverting ORDER → NOTICE still signed
			WHEN 4 THEN 'ORDER_SIGNED'    -- Reverting CERT → ORDER still signed
			ELSE NULL
		END;

	ELSE
		-- SINGLE MODE: revert only the target stage
		-- (revert_single_stage still handles parent_document_id children,
		--  e.g. reverting ORDER will still delete its CERTs underneath)
		IF v_root_id = p_document_id THEN
			-- Target IS the root PLAN — revert doc_sends but don't soft-delete
			v_single_result := revert_single_stage(p_document_id, p_reverted_by, TRUE);
		ELSE
			v_single_result := revert_single_stage(p_document_id, p_reverted_by, FALSE);
		END IF;
		v_sibling_results := v_sibling_results || v_single_result;

		-- Root status: find the latest ACTIVE stage still in the chain
		-- to determine what the root PLAN status should be
		SELECT MAX(get_business_trip_stage_order(idt.code))
		INTO v_latest_active_stage_order
		FROM internal_document_relations idr
		JOIN documents d ON d.id::TEXT = idr.child_id AND d.is_deleted IS NOT TRUE
		JOIN internal_doc_types idt ON idt.id = d.internal_doc_type_id
		WHERE idr.parent_id = v_root_id
		  AND d.id != p_document_id;  -- exclude the one we just reverted

		-- Map the latest remaining active stage to root status
		IF v_latest_active_stage_order IS NULL OR v_latest_active_stage_order = 0 THEN
			-- No other stages left — check if target was root
			IF v_root_id = p_document_id THEN
				v_target_root_status := 'ON_REVIEW';
			ELSE
				v_target_root_status := 'SIGNED';  -- Only PLAN remains
			END IF;
		ELSE
			-- Determine status from the latest remaining stage's actual status
			SELECT CASE
				WHEN id.status = 'SIGNED' THEN
					CASE get_business_trip_stage_order(idt.code)
						WHEN 2 THEN 'NOTICE_SIGNED'
						WHEN 3 THEN 'ORDER_SIGNED'
						WHEN 4 THEN 'CERTIFICATE_SIGNED'
						ELSE 'SIGNED'
					END
				ELSE
					CASE get_business_trip_stage_order(idt.code)
						WHEN 2 THEN 'NOTICE_CREATED'
						WHEN 3 THEN 'ORDER_CREATED'
						WHEN 4 THEN 'CERTIFICATE_CREATED'
						ELSE 'SIGNED'
					END
			END INTO v_target_root_status
			FROM internal_document_relations idr
			JOIN documents d ON d.id::TEXT = idr.child_id AND d.is_deleted IS NOT TRUE
			JOIN internal_doc_types idt ON idt.id = d.internal_doc_type_id
			JOIN internal_documents id ON id.document_id = d.id AND id.is_deleted IS NOT TRUE
			WHERE idr.parent_id = v_root_id
			  AND d.id != p_document_id
			ORDER BY get_business_trip_stage_order(idt.code) DESC
			LIMIT 1;
		END IF;
	END IF;

	-- ========================================
	-- 4. Update root PLAN status
	-- ========================================
	IF v_target_root_status IS NOT NULL AND v_root_id IS NOT NULL THEN
		UPDATE internal_documents
		SET status = v_target_root_status,
		    updated_at = NOW()
		WHERE document_id = v_root_id
		  AND is_deleted IS NOT TRUE;

		-- Also update the flow state tracking table
		UPDATE internal_document_flow_state
		SET current_flow_status = v_target_root_status,
		    updated_at = NOW()
		WHERE root_document_id = v_root_id;

		-- Record a flow event for audit
		INSERT INTO internal_document_flow_events (id, root_document_id, trigger_document_id, event_type, to_status)
		VALUES (
			encode(gen_random_bytes(12), 'hex')::TEXT,
			v_root_id,
			p_document_id,
			'REVERT',
			v_target_root_status
		);
	END IF;

	-- ========================================
	-- 5. Restore previous stage's status to SIGNED
	-- ========================================
	-- When reverting ORDER → NOTICE should be SIGNED
	-- When reverting CERTIFICATE → ORDER should be SIGNED
	-- When reverting NOTICE → PLAN was already handled above
	-- Find the stage just before the target and set it to SIGNED
	IF v_target_stage_order > 1 THEN
		UPDATE internal_documents
		SET status = 'SIGNED',
		    updated_at = NOW()
		WHERE document_id IN (
			SELECT d.id
			FROM internal_document_relations idr
			JOIN documents d ON d.id::TEXT = idr.child_id AND d.is_deleted IS NOT TRUE
			JOIN internal_doc_types idt ON idt.id = d.internal_doc_type_id
			WHERE idr.parent_id = v_root_id
			  AND get_business_trip_stage_order(idt.code) = v_target_stage_order - 1
		)
		AND is_deleted IS NOT TRUE;
	END IF;

	-- ========================================
	-- BUILD RESULT
	-- ========================================
	v_result := jsonb_build_object(
		'success', TRUE,
		'document_id', p_document_id,
		'root_plan_id', v_root_id,
		'target_stage', v_doc_type_code,
		'target_stage_order', v_target_stage_order,
		'cascade_later_stages', p_cascade_later_stages,
		'root_status_reverted_to', v_target_root_status,
		'stages_reverted', v_sibling_results
	);

	RETURN v_result;
END;
$$;


--
-- Name: revert_document_action_generic(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.revert_document_action_generic(p_document_id text, p_action text DEFAULT 'signed'::text, p_reverted_by text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_results JSONB := '[]'::JSONB;
	v_doc_send RECORD;
	v_single_result JSONB;
BEGIN
	IF p_action = 'signed' THEN
		-- Revert all signed doc_sends for this document
		FOR v_doc_send IN
			SELECT ds.id
			FROM document_send ds
			WHERE ds.document_id = p_document_id
			  AND ds.status = 30 -- SIGNED
			  AND ds.is_deleted IS NOT TRUE
			ORDER BY ds.action_at DESC
		LOOP
			v_single_result := revert_document_send_sign(
				v_doc_send.id, p_reverted_by, TRUE
			);
			v_results := v_results || v_single_result;
		END LOOP;

	ELSIF p_action = 'business_trip_stage' THEN
		-- Revert a business trip stage + all later stages (cascade)
		v_results := revert_business_trip_stage(p_document_id, p_reverted_by, TRUE);

	ELSIF p_action = 'business_trip_stage_only' THEN
		-- Revert ONLY the target stage, leave later stages untouched
		v_results := revert_business_trip_stage(p_document_id, p_reverted_by, FALSE);

	-- ============================================
	-- Future action types can be added here:
	-- ============================================
	-- ELSIF p_action = 'send_to_sign' THEN
	--     ...
	-- ELSIF p_action = 'agreement' THEN
	--     ...
	-- ELSIF p_action = 'resolution' THEN
	--     ...
	END IF;

	RETURN jsonb_build_object(
		'success', TRUE,
		'document_id', p_document_id,
		'action_reverted', p_action,
		'details', v_results
	);
END;
$$;


--
-- Name: revert_document_send_sign(text, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.revert_document_send_sign(p_doc_send_id text, p_reverted_by text DEFAULT NULL::text, p_revert_children boolean DEFAULT true) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_doc_send RECORD;
	v_document RECORD;
	v_tasks_deleted INT := 0;
	v_drafts_restored INT := 0;
	v_signatures_deleted INT := 0;
	v_exec_flows_deleted INT := 0;
	v_children_deleted INT := 0;
	v_main_file_reverted BOOLEAN := FALSE;
	v_original_main_file JSONB;
	v_result JSONB;
BEGIN
	-- ========================================
	-- VALIDATE: Get and check document_send
	-- ========================================
	SELECT ds.id, ds.document_id, ds.status, ds.fishka_file, ds.recipient_user_id,
	       ds.menu_type, ds.sign_type, ds.db_id, ds.is_deleted
	INTO v_doc_send
	FROM document_send ds
	WHERE ds.id = p_doc_send_id AND ds.is_deleted IS NOT TRUE;

	IF v_doc_send IS NULL THEN
		RAISE EXCEPTION 'document_send not found: %', p_doc_send_id;
	END IF;

	IF v_doc_send.status != 30 THEN -- 30 = DocSendStatus.SIGNED
		RAISE EXCEPTION 'document_send is not signed (status=%)', v_doc_send.status;
	END IF;

	-- ========================================
	-- VALIDATE: Get document info
	-- ========================================
	SELECT d.id, d.type_id, d.auto_reg_generate, d.internal_doc_type_id,
	       d.registration_number, d.status AS doc_status
	INTO v_document
	FROM documents d
	WHERE d.id = v_doc_send.document_id AND d.is_deleted IS NOT TRUE;

	IF v_document IS NULL THEN
		RAISE EXCEPTION 'document not found for doc_send: %', p_doc_send_id;
	END IF;

	-- ========================================
	-- STEP 1: Revert document_send status
	-- ========================================
	-- Reset status from SIGNED(30) back to SEND_TO_SIGN(8)
	-- Clear the signed file and action metadata
	UPDATE document_send
	SET status = 8,             -- SEND_TO_SIGN
	    fishka_file = NULL,
	    action_at = NULL,
	    action_by = NULL,
	    updated_at = NOW()
	WHERE id = p_doc_send_id;

	-- ========================================
	-- STEP 2: Delete digital signatures
	-- ========================================
	-- Hard-delete because crypto signatures for reverted actions should not persist
	WITH deleted AS (
		DELETE FROM document_send_signature
		WHERE document_send_id = p_doc_send_id
		RETURNING id
	)
	SELECT COUNT(*) INTO v_signatures_deleted FROM deleted;

	-- ========================================
	-- STEP 3: Revert document status
	-- ========================================
	-- Only revert if NO OTHER doc_sends are still signed
	IF NOT EXISTS (
		SELECT 1 FROM document_send
		WHERE document_id = v_doc_send.document_id
		  AND id != p_doc_send_id
		  AND status = 30
		  AND is_deleted IS NOT TRUE
	) THEN
		-- No other signed sends → revert main document status to NEW
		UPDATE documents
		SET status = 1, -- DocumentStatus.NEW
		    updated_at = NOW()
		WHERE id = v_doc_send.document_id;

		-- Clear auto-generated registration number if applicable
		IF v_document.auto_reg_generate = TRUE THEN
			UPDATE documents
			SET registration_number = NULL
			WHERE id = v_doc_send.document_id;
		END IF;
	END IF;

	-- ========================================
	-- STEP 3b: Restore original main_file from document_changes
	-- ========================================
	-- When signing (multi-sign first-time), documents.main_file gets replaced
	-- with the signed output file. document_changes stores the original in old_value.
	-- We restore it here if a change was recorded.
	SELECT old_value::JSONB INTO v_original_main_file
	FROM document_changes
	WHERE main_id = v_doc_send.document_id
	  AND key_name = 'main_file'
	  AND is_deleted = FALSE
	ORDER BY created_at DESC
	LIMIT 1;

	IF v_original_main_file IS NOT NULL THEN
		UPDATE documents
		SET main_file = v_original_main_file
		WHERE id = v_doc_send.document_id;

		v_main_file_reverted := TRUE;
	END IF;

	-- Also revert the file's signed_file flag in the files table
	-- The signing process sets info.signed_file = true on the output file
	-- We don't revert this because the file itself was genuinely signed;
	-- we only restore the document's reference to the original unsigned file.

	-- ========================================
	-- STEP 4: Revert internal_documents status
	-- ========================================
	-- If this is an internal document, revert status from SIGNED → ON_REVIEW
	IF v_document.internal_doc_type_id IS NOT NULL THEN
		UPDATE internal_documents
		SET status = 'ON_REVIEW',
		    updated_at = NOW()
		WHERE document_id = v_doc_send.document_id
		  AND is_deleted IS NOT TRUE;
	END IF;

	-- ========================================
	-- STEP 5: Revert business trip status
	-- ========================================
	-- Only applies if document has a business_trip record in SIGNED status
	UPDATE document_business_trip
	SET status = 1 -- DocumentBusinessTripStatus.NEW
	WHERE document_id = v_doc_send.document_id
	  AND is_deleted IS NOT TRUE
	  AND status = 2; -- Only if currently SIGNED

	-- ========================================
	-- STEP 6: Soft-delete tasks created from draft
	-- ========================================
	-- Tasks are linked to doc_send via tasks.document_send_id
	-- Also cascade to task_recipients and task_controllers
	WITH tasks_to_delete AS (
		SELECT t.id
		FROM tasks t
		WHERE t.document_send_id = p_doc_send_id
		  AND t.is_deleted IS NOT TRUE
	),
	deleted_tasks AS (
		UPDATE tasks
		SET is_deleted = TRUE, deleted_at = NOW()
		WHERE id IN (SELECT id FROM tasks_to_delete)
		RETURNING id
	),
	deleted_recipients AS (
		UPDATE task_recipients
		SET is_deleted = TRUE
		WHERE task_id IN (SELECT id FROM tasks_to_delete)
		  AND is_deleted IS NOT TRUE
		RETURNING id
	),
	deleted_controllers AS (
		UPDATE task_controllers
		SET is_deleted = TRUE
		WHERE task_id IN (SELECT id FROM tasks_to_delete)
		  AND is_deleted IS NOT TRUE
		RETURNING id
	)
	SELECT COUNT(*) INTO v_tasks_deleted FROM deleted_tasks;

	-- ========================================
	-- STEP 7: Restore draft tasks
	-- ========================================
	-- Un-delete drafts so they can be used when re-signing
	WITH restored AS (
		UPDATE task_draft_until_sign
		SET is_deleted = FALSE
		WHERE document_send_id = p_doc_send_id
		  AND is_deleted = TRUE
		RETURNING id
	)
	SELECT COUNT(*) INTO v_drafts_restored FROM restored;

	-- ========================================
	-- STEP 8: Soft-delete execution flow records
	-- ========================================
	-- Delete execution flows for the doc_send itself
	WITH deleted_flows AS (
		UPDATE execution_flow
		SET is_deleted = TRUE, deleted_at = NOW()
		WHERE data_id = p_doc_send_id
		  AND is_deleted IS NOT TRUE
		RETURNING id
	)
	SELECT COUNT(*) INTO v_exec_flows_deleted FROM deleted_flows;

	-- Also delete execution flows for the tasks we just soft-deleted
	UPDATE execution_flow
	SET is_deleted = TRUE, deleted_at = NOW()
	WHERE data_id IN (
		SELECT id::TEXT FROM tasks
		WHERE document_send_id = p_doc_send_id AND is_deleted = TRUE
	)
	AND is_deleted IS NOT TRUE;

	-- ========================================
	-- STEP 9: Soft-delete repeatable plans
	-- ========================================
	DELETE FROM repeatable_plan
	WHERE first_task_id IN (
		SELECT id FROM tasks
		WHERE document_send_id = p_doc_send_id AND is_deleted = TRUE
	);

	-- ========================================
	-- STEP 10: Log the revert action (audit trail)
	-- ========================================
	INSERT INTO document_actions (id, document_id, action, action_by, action_at, data)
	VALUES (
		encode(gen_random_bytes(12), 'hex'),
		v_doc_send.document_id,
		'revert_signed',
		COALESCE(p_reverted_by, v_doc_send.recipient_user_id),
		NOW(),
		jsonb_build_object(
			'reverted_doc_send_id', p_doc_send_id,
			'tasks_deleted', v_tasks_deleted,
			'drafts_restored', v_drafts_restored,
			'signatures_deleted', v_signatures_deleted
		)
	);

	-- ========================================
	-- STEP 11: Cascade soft-delete child documents
	-- ========================================
	-- For business trip: signing ORDER auto-creates CERTIFICATEs as children
	-- For internal docs: signing may create recipient copies as children
	IF p_revert_children = TRUE THEN
		WITH children AS (
			SELECT d.id
			FROM documents d
			WHERE d.parent_document_id = v_doc_send.document_id
			  AND d.is_deleted IS NOT TRUE
		),
		deleted_children AS (
			UPDATE documents
			SET is_deleted = TRUE,
			    deleted_at = NOW(),
			    deleted_by = COALESCE(p_reverted_by, v_doc_send.recipient_user_id)
			WHERE id IN (SELECT id FROM children)
			RETURNING id
		),
		-- Cascade: soft-delete children's doc_sends
		deleted_child_sends AS (
			UPDATE document_send
			SET is_deleted = TRUE, deleted_at = NOW()
			WHERE document_id IN (SELECT id FROM deleted_children)
			  AND is_deleted IS NOT TRUE
			RETURNING id
		),
		-- Cascade: soft-delete children's internal_documents
		deleted_child_internals AS (
			UPDATE internal_documents
			SET is_deleted = TRUE
			WHERE document_id IN (SELECT id FROM deleted_children)
			  AND is_deleted IS NOT TRUE
			RETURNING id
		),
		-- Cascade: soft-delete children's execution_flow records
		deleted_child_flows AS (
			UPDATE execution_flow
			SET is_deleted = TRUE, deleted_at = NOW()
			WHERE data_id IN (SELECT id::TEXT FROM deleted_children)
			  AND is_deleted IS NOT TRUE
			RETURNING id
		),
		-- Cascade: delete children's signatures
		deleted_child_signatures AS (
			DELETE FROM document_send_signature
			WHERE document_send_id IN (
				SELECT ds.id FROM document_send ds
				WHERE ds.document_id IN (SELECT id FROM deleted_children)
			)
			RETURNING id
		)
		SELECT COUNT(*) INTO v_children_deleted FROM deleted_children;
	END IF;

	-- ========================================
	-- BUILD RESULT
	-- ========================================
	v_result := jsonb_build_object(
		'success', TRUE,
		'doc_send_id', p_doc_send_id,
		'document_id', v_doc_send.document_id,
		'signatures_deleted', v_signatures_deleted,
		'tasks_deleted', v_tasks_deleted,
		'drafts_restored', v_drafts_restored,
		'execution_flows_deleted', v_exec_flows_deleted,
		'children_deleted', v_children_deleted,
		'main_file_reverted', v_main_file_reverted
	);

	RETURN v_result;
END;
$$;


--
-- Name: revert_single_stage(text, text, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.revert_single_stage(p_document_id text, p_reverted_by text DEFAULT NULL::text, p_is_root boolean DEFAULT false) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_doc RECORD;
	v_doc_send RECORD;
	v_child RECORD;
	v_children_deleted INT := 0;
	v_result JSONB;
BEGIN
	-- 1. Get the document
	SELECT d.id, d.type_id, d.internal_doc_type_id, d.parent_document_id
	INTO v_doc
	FROM documents d
	WHERE d.id = p_document_id AND d.is_deleted IS NOT TRUE;

	IF v_doc IS NULL THEN
		RETURN jsonb_build_object('success', TRUE, 'document_id', p_document_id, 'skipped', TRUE);
	END IF;

	-- 2. Soft-delete all children (NO revert — just cascade delete)
	--    Children are dependent records, not independent stages.
	FOR v_child IN
		SELECT d.id
		FROM documents d
		WHERE d.parent_document_id = p_document_id
		  AND d.is_deleted IS NOT TRUE
		ORDER BY d.created_at DESC
	LOOP
		PERFORM soft_delete_document_cascade(v_child.id, p_reverted_by);
		v_children_deleted := v_children_deleted + 1;
	END LOOP;

	-- 3. Revert signed doc_sends (full signing undo — only for main stages)
	FOR v_doc_send IN
		SELECT ds.id
		FROM document_send ds
		WHERE ds.document_id = p_document_id
		  AND ds.status = 30 -- SIGNED
		  AND ds.is_deleted IS NOT TRUE
	LOOP
		PERFORM revert_document_send_sign(v_doc_send.id, p_reverted_by, FALSE);
	END LOOP;

	-- 4. Soft-delete this document (unless it's the root PLAN)
	IF p_is_root IS NOT TRUE THEN
		UPDATE documents
		SET is_deleted = TRUE,
		    deleted_at = NOW(),
		    deleted_by = p_reverted_by
		WHERE id = p_document_id;

		UPDATE internal_documents
		SET is_deleted = TRUE
		WHERE document_id = p_document_id AND is_deleted IS NOT TRUE;

		UPDATE document_send
		SET is_deleted = TRUE, deleted_at = NOW()
		WHERE document_id = p_document_id AND is_deleted IS NOT TRUE;

		UPDATE execution_flow
		SET is_deleted = TRUE, deleted_at = NOW()
		WHERE data_id = p_document_id AND is_deleted IS NOT TRUE;

		UPDATE execution_flow
		SET is_deleted = TRUE, deleted_at = NOW()
		WHERE data_id IN (
			SELECT id::TEXT FROM document_send
			WHERE document_id = p_document_id
		)
		AND is_deleted IS NOT TRUE;

		DELETE FROM internal_document_relations
		WHERE child_id = p_document_id;
	END IF;

	v_result := jsonb_build_object(
		'success', TRUE,
		'document_id', p_document_id,
		'is_root', p_is_root,
		'children_soft_deleted', v_children_deleted
	);

	RETURN v_result;
END;
$$;


--
-- Name: send_kafka_process_set_inactive(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.send_kafka_process_set_inactive() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    update kafka_processes set is_active = false where data  = new.data
                                                                and topic = new.topic;

           RETURN new;
END;
$$;


--
-- Name: send_task_set_inactive(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.send_task_set_inactive() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    update recipient_answer_actions
    set active = 0
    where task_id = new.task_id
      and recipient_id = new.recipient_id
      and document_id = new.document_id;
    RETURN new;
END;
$$;


--
-- Name: set_document_signer_type(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_document_signer_type() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.user_id IS NOT NULL
       AND NEW.org_id = (SELECT value FROM app_constants WHERE name = 'ADM_ORG_ID') THEN
        NEW.type := 2;
    ELSE
        NEW.type := 1;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: set_signer_type_to_document_send(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_signer_type_to_document_send() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if (new.recipient_user_id is not null
        and new.doc_signer_org_id = (
            select value from app_constants where name = 'ADM_ORG_ID'
        )
    ) then
        new.type := 'INTERNAL';
    else
        new.type := 'EXTERNAL';
    end if;
    return new;
end;
$$;


--
-- Name: set_user_personal_code(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_user_personal_code() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Only set personal_code if it's NULL or empty
    IF NEW.personal_code IS NULL OR NEW.personal_code = '' THEN
        NEW.personal_code = user_unique_code();
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: short_full_name(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.short_full_name(first_name text, last_name text, middle_name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    result TEXT;
BEGIN
    -- Start with first name
    result := trim(first_name);

    -- Add last name initial
    IF last_name IS NOT NULL AND length(trim(last_name)) > 0 THEN
        result := result || ' ' || left(trim(last_name), 1) || '.';
    END IF;

    -- Add middle name initial (WITHOUT trailing dot at the end)
    IF middle_name IS NOT NULL AND length(trim(middle_name)) > 0 THEN
        result := result || left(trim(middle_name), 1);
    END IF;

    RETURN result;
END;
$$;


--
-- Name: short_user_name(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.short_user_name(first_name character varying DEFAULT NULL::character varying, middle_name character varying DEFAULT NULL::character varying, last_name character varying DEFAULT NULL::character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE nm VARCHAR DEFAULT ''; b VARCHAR; k VARCHAR; i VARCHAR; l SMALLINT;
BEGIN
    nm = last_name;
    IF middle_name ILIKE 'xxx' THEN middle_name = NULL; END IF;
    FOREACH i IN ARRAY ARRAY[middle_name, first_name]
    LOOP
        IF length(COALESCE(i, '')) > 1 THEN
			l = 1;
			b = lower(substr(i, 1, 1));
			k = lower(substr(i, 2, 1));
			IF b IN ('c', 's') AND k = 'h' THEN l = 2; END IF;
			IF b IN ('o', 'g') AND k ~ '\W' THEN l = 2; END IF;
			nm = substr(i, 1, l) || '.' || nm;
		END IF;
	END LOOP;
    RETURN nm;
END;
$$;


--
-- Name: soft_delete_document_cascade(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.soft_delete_document_cascade(p_document_id text, p_reverted_by text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	v_child RECORD;
BEGIN
	-- 1. Recursively soft-delete children first
	FOR v_child IN
		SELECT d.id
		FROM documents d
		WHERE d.parent_document_id = p_document_id
		  AND d.is_deleted IS NOT TRUE
	LOOP
		PERFORM soft_delete_document_cascade(v_child.id, p_reverted_by);
	END LOOP;

	-- 2. Soft-delete the document itself
	UPDATE documents
	SET is_deleted = TRUE, deleted_at = NOW(), deleted_by = p_reverted_by
	WHERE id = p_document_id AND is_deleted IS NOT TRUE;

	-- 3. Soft-delete related records
	UPDATE internal_documents
	SET is_deleted = TRUE
	WHERE document_id = p_document_id AND is_deleted IS NOT TRUE;

	UPDATE document_send
	SET is_deleted = TRUE, deleted_at = NOW()
	WHERE document_id = p_document_id AND is_deleted IS NOT TRUE;

	UPDATE execution_flow
	SET is_deleted = TRUE, deleted_at = NOW()
	WHERE data_id = p_document_id AND is_deleted IS NOT TRUE;

	UPDATE execution_flow
	SET is_deleted = TRUE, deleted_at = NOW()
	WHERE data_id IN (
		SELECT id::TEXT FROM document_send WHERE document_id = p_document_id
	)
	AND is_deleted IS NOT TRUE;

	DELETE FROM internal_document_relations
	WHERE child_id = p_document_id;
END;
$$;


--
-- Name: to_inactive_agreements(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.to_inactive_agreements() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          UPDATE document_agreement
          SET active = 0
          WHERE document_id = NEW.document_id
            AND recipient_user_id = NEW.recipient_user_id
            AND id <> NEW.id;
          RETURN NEW;
        END;
        $$;


--
-- Name: update_background_checks_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_background_checks_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_document_is_deleted(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_document_is_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
    IF (TG_OP = 'UPDATE' AND old.is_deleted IS NOT TRUE AND new.is_deleted)
    THEN
        IF tg_table_name = 'documents' THEN
            UPDATE task_draft_until_sign
            SET is_deleted      = TRUE
            WHERE document_id = new.id;

            UPDATE tasks
            SET is_deleted      = TRUE,
                deleted_by      = new.deleted_by,
                deleted_at      = now()
            WHERE document_id = new.id;

            UPDATE document_send
            SET is_deleted = TRUE,
            deleted_by = new.deleted_by
            WHERE document_id = new.id;

            UPDATE document_send_signature
            SET is_deleted = TRUE
            WHERE document_id = new.id;

            UPDATE incoming_documents
            SET is_deleted = TRUE
            WHERE document_id = new.id;

            update normative_documents
            set is_deleted = true
            WHERE document_id = new.id;

            delete
            from linked_document
            WHERE document_id = new.id;

            update document_outgoing
            set is_deleted = true
            WHERE document_id = new.id;

            UPDATE task_recipients
            SET is_deleted      = TRUE,
                deleted_by      = new.deleted_by,
                deleted_at      = now()
            WHERE document_id = new.id;

            UPDATE document_agreement
            SET is_deleted      = TRUE
            WHERE document_id = new.id;

        END IF;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: update_event_handlers_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_event_handlers_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_event_pool_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_event_pool_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_integrations_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_integrations_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_internal_notifications_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_internal_notifications_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	NEW.updated_at = NOW();
	RETURN NEW;
END;
$$;


--
-- Name: update_record_types_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_record_types_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_records_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_records_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_static_files_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_static_files_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


--
-- Name: update_updated_time(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_time() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_time = EXTRACT(EPOCH FROM clock_timestamp()) * 1000000;
    RETURN NEW;
END;
$$;


--
-- Name: update_user_parent_department_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_user_parent_department_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    -- Only update if department_id actually changed or it's an INSERT
    if (TG_OP = 'INSERT') or (TG_OP = 'UPDATE') then
        if NEW.department_id is not null then
            NEW.parent_department_id := (
                select case
                           when nlevel(dep.parent_hierarchy) >= 3 then subltree(dep.parent_hierarchy, 2, 3)::varchar
                           else dep.id
                       end
                from departments as dep
                where dep.id = NEW.department_id
                  and dep.is_deleted is false
            );
        else
            NEW.parent_department_id := null;
        end if;
    end if;

    return NEW;
end;
$$;


--
-- Name: updated_time(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.updated_time() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF current_query() LIKE '%#@_UPDATE_TIME_TRIGGER_OFF_@#%' THEN RETURN new; END IF;
    RAISE NOTICE 'TRIGGER RUN row_updated FOR TABLE %, ACTION: %, TIME: %',
        tg_table_schema || '.' || tg_table_name, tg_op, clock_timestamp();
	BEGIN
		new.updated_time = EXTRACT(EPOCH FROM clock_timestamp()) * 1000000;
    EXCEPTION WHEN undefined_column THEN
        RAISE NOTICE 'Not exists column "updated_time" on the table: "%"', tg_table_name;
    END;
    RETURN new;
END;
$$;


--
-- Name: user_after_insert_trigger_func(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.user_after_insert_trigger_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO document_signers (id, created_at, org_id, phone_number, user_id, position,
                                  full_name)
    VALUES (generate_object_id(), now(), new.db_id, null, new.id, 3, new.full_name);

    RETURN NEW;
END;
$$;


--
-- Name: user_unique_code(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.user_unique_code() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    code              varchar;
    code_str          varchar;
    code_number       varchar;
    code_user         varchar;
    str_black_list    varchar[] = ARRAY ['XUY','SEX','KOT','LOX']:: varchar[];
    number_black_list varchar[] = ARRAY ['1111','2222','3333','4444','5555','6666','7777','8888','9999','0000']:: varchar[];
    black_str boolean;
    black_num boolean;
BEGIN
    code_str = array_to_string(
            ARRAY(
                    SELECT chr((65 + round(random() * 25)) :: integer) FROM generate_series(1, 3)), '');
    code_number = array_to_string(
            ARRAY(
                    SELECT chr((48 + round(random() * 9)) :: integer) FROM generate_series(1, 4)), '');
    black_str  = exists(select * from unnest(str_black_list) s where s = code_str);
    black_num  = exists(select * from unnest(number_black_list) s where s = code_number);
    IF (
            black_str or
            black_num
        ) THEN
        return user_unique_code();
    END IF;
    code = concat(code_str, code_number);
    code_user = (select id from users where personal_code = code::varchar);
    IF (code_user is not null) THEN
        return user_unique_code();
    END IF;
    return code;
END;
$$;


--
-- Name: validate_event_handlers_actions(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_event_handlers_actions() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    action_item JSONB;
BEGIN
    -- Check that actions is an array
    IF jsonb_typeof(NEW.actions) != 'array' THEN
        RAISE EXCEPTION 'actions must be an array';
    END IF;

    -- Check minItems: 1
    IF jsonb_array_length(NEW.actions) < 1 THEN
        RAISE EXCEPTION 'actions must have at least 1 item';
    END IF;

    -- Validate each action object
    FOR action_item IN SELECT * FROM jsonb_array_elements(NEW.actions)
    LOOP
        -- Check that each item is an object
        IF jsonb_typeof(action_item) != 'object' THEN
            RAISE EXCEPTION 'All action items must be objects';
        END IF;

        -- Check required field: name
        IF NOT (action_item ? 'name') THEN
            RAISE EXCEPTION 'Each action must have name field';
        END IF;

        -- Validate name: string, minLength: 1
        IF jsonb_typeof(action_item->'name') != 'string' OR LENGTH(action_item->>'name') < 1 THEN
            RAISE EXCEPTION 'action name must be string with minLength: 1';
        END IF;

        -- Validate optional fields
        -- description: string, minLength: 1
        IF action_item ? 'description' THEN
            IF jsonb_typeof(action_item->'description') != 'string' OR LENGTH(action_item->>'description') < 1 THEN
                RAISE EXCEPTION 'action description must be string with minLength: 1';
            END IF;
        END IF;

        -- settings: object (optional)
        IF action_item ? 'settings' THEN
            IF jsonb_typeof(action_item->'settings') != 'object' THEN
                RAISE EXCEPTION 'action settings must be an object';
            END IF;

            -- Validate settings.sourceSystem: string, minLength: 1 (optional)
            IF action_item->'settings' ? 'sourceSystem' THEN
                IF jsonb_typeof(action_item->'settings'->'sourceSystem') != 'string' OR LENGTH(action_item->'settings'->>'sourceSystem') < 1 THEN
                    RAISE EXCEPTION 'settings.sourceSystem must be string with minLength: 1';
                END IF;
            END IF;

            -- Validate settings.shouldProcess: object (optional)
            IF action_item->'settings' ? 'shouldProcess' THEN
                IF jsonb_typeof(action_item->'settings'->'shouldProcess') != 'object' THEN
                    RAISE EXCEPTION 'settings.shouldProcess must be an object';
                END IF;

                -- Check required fields: value and schema
                IF NOT (action_item->'settings'->'shouldProcess' ? 'value' AND action_item->'settings'->'shouldProcess' ? 'schema') THEN
                    RAISE EXCEPTION 'settings.shouldProcess must have value and schema fields';
                END IF;

                -- Validate schema: object
                IF jsonb_typeof(action_item->'settings'->'shouldProcess'->'schema') != 'object' THEN
                    RAISE EXCEPTION 'settings.shouldProcess.schema must be an object';
                END IF;

                -- Validate value: oneOf two object types
                DECLARE
                    value_obj JSONB := action_item->'settings'->'shouldProcess'->'value';
                    value_type TEXT := jsonb_typeof(value_obj);
                BEGIN
                    IF value_type != 'object' THEN
                        RAISE EXCEPTION 'settings.shouldProcess.value must be an object';
                    END IF;

                    -- Check if it matches first type: { pipeline: array, ifNotFound?: int, ifNotFoundMessage?: string }
                    IF value_obj ? 'pipeline' THEN
                        IF jsonb_typeof(value_obj->'pipeline') != 'array' THEN
                            RAISE EXCEPTION 'settings.shouldProcess.value.pipeline must be an array';
                        END IF;
                        -- Validate optional fields
                        IF value_obj ? 'ifNotFound' AND jsonb_typeof(value_obj->'ifNotFound') != 'number' THEN
                            RAISE EXCEPTION 'settings.shouldProcess.value.ifNotFound must be a number';
                        END IF;
                        IF value_obj ? 'ifNotFoundMessage' AND (jsonb_typeof(value_obj->'ifNotFoundMessage') != 'string' OR LENGTH(value_obj->>'ifNotFoundMessage') < 1) THEN
                            RAISE EXCEPTION 'settings.shouldProcess.value.ifNotFoundMessage must be string with minLength: 1';
                        END IF;
                        -- Check additionalProperties: false for this type
                        DECLARE
                            allowed_keys TEXT[] := ARRAY['pipeline', 'ifNotFound', 'ifNotFoundMessage'];
                            key TEXT;
                        BEGIN
                            FOR key IN SELECT jsonb_object_keys(value_obj)
                            LOOP
                                IF NOT (key = ANY(allowed_keys)) THEN
                                    RAISE EXCEPTION 'settings.shouldProcess.value has unexpected property: % (additionalProperties: false)', key;
                                END IF;
                            END LOOP;
                        END;
                    -- Check if it matches second type: { source?: string, path: string, ifNotFound?: int, ifNotFoundMessage?: string }
                    ELSIF value_obj ? 'path' THEN
                        IF jsonb_typeof(value_obj->'path') != 'string' OR LENGTH(value_obj->>'path') < 1 THEN
                            RAISE EXCEPTION 'settings.shouldProcess.value.path must be string with minLength: 1';
                        END IF;
                        -- Validate optional source
                        IF value_obj ? 'source' AND (jsonb_typeof(value_obj->'source') != 'string' OR LENGTH(value_obj->>'source') < 1) THEN
                            RAISE EXCEPTION 'settings.shouldProcess.value.source must be string with minLength: 1';
                        END IF;
                        -- Validate optional ifNotFound
                        IF value_obj ? 'ifNotFound' AND jsonb_typeof(value_obj->'ifNotFound') != 'number' THEN
                            RAISE EXCEPTION 'settings.shouldProcess.value.ifNotFound must be a number';
                        END IF;
                        -- Validate optional ifNotFoundMessage
                        IF value_obj ? 'ifNotFoundMessage' AND (jsonb_typeof(value_obj->'ifNotFoundMessage') != 'string' OR LENGTH(value_obj->>'ifNotFoundMessage') < 1) THEN
                            RAISE EXCEPTION 'settings.shouldProcess.value.ifNotFoundMessage must be string with minLength: 1';
                        END IF;
                        -- Check additionalProperties: false for this type
                        DECLARE
                            allowed_keys TEXT[] := ARRAY['source', 'path', 'ifNotFound', 'ifNotFoundMessage'];
                            key TEXT;
                        BEGIN
                            FOR key IN SELECT jsonb_object_keys(value_obj)
                            LOOP
                                IF NOT (key = ANY(allowed_keys)) THEN
                                    RAISE EXCEPTION 'settings.shouldProcess.value has unexpected property: % (additionalProperties: false)', key;
                                END IF;
                            END LOOP;
                        END;
                    ELSE
                        RAISE EXCEPTION 'settings.shouldProcess.value must have either pipeline or path field';
                    END IF;
                END;

                -- Check additionalProperties: false for shouldProcess
                DECLARE
                    allowed_keys TEXT[] := ARRAY['value', 'schema'];
                    key TEXT;
                BEGIN
                    FOR key IN SELECT jsonb_object_keys(action_item->'settings'->'shouldProcess')
                    LOOP
                        IF NOT (key = ANY(allowed_keys)) THEN
                            RAISE EXCEPTION 'settings.shouldProcess has unexpected property: % (additionalProperties: false)', key;
                        END IF;
                    END LOOP;
                END;
            END IF;

            -- Check additionalProperties: false for settings
            DECLARE
                allowed_keys TEXT[] := ARRAY['sourceSystem', 'shouldProcess'];
                key TEXT;
            BEGIN
                FOR key IN SELECT jsonb_object_keys(action_item->'settings')
                LOOP
                    IF NOT (key = ANY(allowed_keys)) THEN
                        RAISE EXCEPTION 'settings has unexpected property: % (additionalProperties: false)', key;
                    END IF;
                END LOOP;
            END;
        END IF;

        -- Check additionalProperties: false for action
        DECLARE
            allowed_keys TEXT[] := ARRAY['name', 'description', 'settings'];
            key TEXT;
        BEGIN
            FOR key IN SELECT jsonb_object_keys(action_item)
            LOOP
                IF NOT (key = ANY(allowed_keys)) THEN
                    RAISE EXCEPTION 'action has unexpected property: % (additionalProperties: false)', key;
                END IF;
            END LOOP;
        END;
    END LOOP;

    RETURN NEW;
END;
$$;


--
-- Name: validate_event_handlers_triggers(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_event_handlers_triggers() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    trigger_item JSONB;
BEGIN
    -- If triggers is NULL, skip validation
    IF NEW.triggers IS NULL THEN
        RETURN NEW;
    END IF;

    -- Check that triggers is an array
    IF jsonb_typeof(NEW.triggers) != 'array' THEN
        RAISE EXCEPTION 'triggers must be an array';
    END IF;

    -- Check minItems: 1
    IF jsonb_array_length(NEW.triggers) < 1 THEN
        RAISE EXCEPTION 'triggers must have at least 1 item';
    END IF;

    -- Validate each trigger object
    FOR trigger_item IN SELECT * FROM jsonb_array_elements(NEW.triggers)
    LOOP
        -- Check that each item is an object
        IF jsonb_typeof(trigger_item) != 'object' THEN
            RAISE EXCEPTION 'All trigger items must be objects';
        END IF;

        -- Check required fields: sourceSystem and event
        IF NOT (trigger_item ? 'sourceSystem' AND trigger_item ? 'event') THEN
            RAISE EXCEPTION 'Each trigger must have sourceSystem and event fields';
        END IF;

        -- Validate sourceSystem (string or array, minLength: 1)
        IF jsonb_typeof(trigger_item->'sourceSystem') = 'string' THEN
            IF LENGTH(trigger_item->>'sourceSystem') < 1 THEN
                RAISE EXCEPTION 'trigger sourceSystem string must have minLength: 1';
            END IF;
        ELSIF jsonb_typeof(trigger_item->'sourceSystem') = 'array' THEN
            IF jsonb_array_length(trigger_item->'sourceSystem') < 1 THEN
                RAISE EXCEPTION 'trigger sourceSystem array must have at least 1 item';
            END IF;
            -- Validate array items are strings with minLength: 1
            -- Note: jsonb string values cast to text include quotes, so we check length >= 3 ("a")
            IF EXISTS (
                SELECT 1 FROM jsonb_array_elements(trigger_item->'sourceSystem') AS ss_item
                WHERE jsonb_typeof(ss_item) != 'string' OR LENGTH(ss_item::text) < 3
            ) THEN
                RAISE EXCEPTION 'All sourceSystem array items must be strings with minLength: 1';
            END IF;
        ELSE
            RAISE EXCEPTION 'trigger sourceSystem must be string or array';
        END IF;

        -- Validate event (string or array, minLength: 1, minItems: 1)
        IF jsonb_typeof(trigger_item->'event') = 'string' THEN
            IF LENGTH(trigger_item->>'event') < 1 THEN
                RAISE EXCEPTION 'trigger event string must have minLength: 1';
            END IF;
        ELSIF jsonb_typeof(trigger_item->'event') = 'array' THEN
            IF jsonb_array_length(trigger_item->'event') < 1 THEN
                RAISE EXCEPTION 'trigger event array must have at least 1 item (minItems: 1)';
            END IF;
            -- Validate array items are strings with minLength: 1
            -- Note: jsonb string values cast to text include quotes, so we check length >= 3 ("a")
            IF EXISTS (
                SELECT 1 FROM jsonb_array_elements(trigger_item->'event') AS ev_item
                WHERE jsonb_typeof(ev_item) != 'string' OR LENGTH(ev_item::text) < 3
            ) THEN
                RAISE EXCEPTION 'All event array items must be strings with minLength: 1';
            END IF;
        ELSE
            RAISE EXCEPTION 'trigger event must be string or array';
        END IF;

        -- Validate optional fields
        -- description: string, minLength: 1
        IF trigger_item ? 'description' THEN
            IF jsonb_typeof(trigger_item->'description') != 'string' OR LENGTH(trigger_item->>'description') < 1 THEN
                RAISE EXCEPTION 'trigger description must be string with minLength: 1';
            END IF;
        END IF;

        -- organization: array/null/objectId
        IF trigger_item ? 'organization' THEN
            IF NOT (jsonb_typeof(trigger_item->'organization') IN ('array', 'null')) THEN
                -- If it's an objectId (string in PostgreSQL), validate it's a valid ID format
                IF jsonb_typeof(trigger_item->'organization') != 'string' OR LENGTH(trigger_item->>'organization') != 24 THEN
                    RAISE EXCEPTION 'trigger organization must be array, null, or valid objectId (24 chars)';
                END IF;
            END IF;
        END IF;

        -- excludeOrganization: array/objectId
        IF trigger_item ? 'excludeOrganization' THEN
            IF jsonb_typeof(trigger_item->'excludeOrganization') = 'array' THEN
                -- Validate array items are objectIds (strings of 24 chars)
                -- Note: jsonb string values cast to text include quotes, so we check length == 26 ("...24 chars...")
                IF EXISTS (
                    SELECT 1 FROM jsonb_array_elements(trigger_item->'excludeOrganization') AS org_item
                    WHERE jsonb_typeof(org_item) != 'string' OR LENGTH(org_item::text) != 26
                ) THEN
                    RAISE EXCEPTION 'All excludeOrganization array items must be valid objectIds (24 chars)';
                END IF;
            ELSIF jsonb_typeof(trigger_item->'excludeOrganization') != 'string' OR LENGTH(trigger_item->>'excludeOrganization') != 24 THEN
                RAISE EXCEPTION 'excludeOrganization must be array or valid objectId (24 chars)';
            END IF;
        END IF;

        -- isEnabled: bool, enum: [false] (optional, but if present must be false)
        IF trigger_item ? 'isEnabled' THEN
            IF jsonb_typeof(trigger_item->'isEnabled') != 'boolean' OR (trigger_item->>'isEnabled')::boolean != false THEN
                RAISE EXCEPTION 'trigger isEnabled must be false when present';
            END IF;
        END IF;

        -- data: object/array (optional)
        IF trigger_item ? 'data' THEN
            IF NOT (jsonb_typeof(trigger_item->'data') IN ('object', 'array')) THEN
                RAISE EXCEPTION 'trigger data must be object or array';
            END IF;
        END IF;

        -- pipeline: array of objects, minItems: 1 (optional)
        IF trigger_item ? 'pipeline' THEN
            IF jsonb_typeof(trigger_item->'pipeline') != 'array' THEN
                RAISE EXCEPTION 'trigger pipeline must be an array';
            END IF;
            IF jsonb_array_length(trigger_item->'pipeline') < 1 THEN
                RAISE EXCEPTION 'trigger pipeline must have at least 1 item (minItems: 1)';
            END IF;
            -- Validate all items are objects
            IF EXISTS (
                SELECT 1 FROM jsonb_array_elements(trigger_item->'pipeline') AS pipe_item
                WHERE jsonb_typeof(pipe_item) != 'object'
            ) THEN
                RAISE EXCEPTION 'All pipeline items must be objects';
            END IF;
        END IF;

        -- jsonSchemaFilter: object (optional)
        IF trigger_item ? 'jsonSchemaFilter' THEN
            IF jsonb_typeof(trigger_item->'jsonSchemaFilter') != 'object' THEN
                RAISE EXCEPTION 'trigger jsonSchemaFilter must be an object';
            END IF;
        END IF;

        -- Check additionalProperties: false (only allow known properties)
        -- This is tricky in PostgreSQL, but we can check that no unexpected top-level keys exist
        -- Expected keys: description, organization, excludeOrganization, sourceSystem, isEnabled, event, data, pipeline, jsonSchemaFilter
        DECLARE
            allowed_keys TEXT[] := ARRAY['description', 'organization', 'excludeOrganization', 'sourceSystem', 'isEnabled', 'event', 'data', 'pipeline', 'jsonSchemaFilter'];
            key TEXT;
        BEGIN
            FOR key IN SELECT jsonb_object_keys(trigger_item)
            LOOP
                IF NOT (key = ANY(allowed_keys)) THEN
                    RAISE EXCEPTION 'trigger has unexpected property: % (additionalProperties: false)', key;
                END IF;
            END LOOP;
        END;
    END LOOP;

    RETURN NEW;
END;
$$;


--
-- Name: validate_event_pool_log(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_event_pool_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.log IS NOT NULL THEN
        -- Check that all log entries are objects
        IF EXISTS (
            SELECT 1 FROM jsonb_array_elements(NEW.log) AS log_entry
            WHERE jsonb_typeof(log_entry) != 'object'
        ) THEN
            RAISE EXCEPTION 'All log entries must be objects';
        END IF;

        -- Check that all log entries have required fields (timestamp, message)
        IF EXISTS (
            SELECT 1 FROM jsonb_array_elements(NEW.log) AS log_entry
            WHERE NOT (log_entry ? 'timestamp' AND log_entry ? 'message')
        ) THEN
            RAISE EXCEPTION 'All log entries must have timestamp and message fields';
        END IF;

        -- Check that timestamp is a valid date/string
        IF EXISTS (
            SELECT 1 FROM jsonb_array_elements(NEW.log) AS log_entry
            WHERE jsonb_typeof(log_entry->'timestamp') NOT IN ('string', 'number')
        ) THEN
            RAISE EXCEPTION 'All log entry timestamps must be valid date values';
        END IF;

        -- Check that message is a string
        IF EXISTS (
            SELECT 1 FROM jsonb_array_elements(NEW.log) AS log_entry
            WHERE jsonb_typeof(log_entry->'message') != 'string'
        ) THEN
            RAISE EXCEPTION 'All log entry messages must be strings';
        END IF;

        -- Check that data field, if present, is an object
        IF EXISTS (
            SELECT 1 FROM jsonb_array_elements(NEW.log) AS log_entry
            WHERE log_entry ? 'data' AND jsonb_typeof(log_entry->'data') != 'object'
        ) THEN
            RAISE EXCEPTION 'Log entry data field must be an object when present';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: access_tokens; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.access_tokens (
    id character varying(24) NOT NULL,
    access_token text NOT NULL,
    access_token_expires_on timestamp with time zone DEFAULT (now() + '18:00:00'::interval) NOT NULL,
    refresh_token text,
    refresh_token_expires_on timestamp with time zone DEFAULT (now() + '7 days'::interval),
    user_id character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    root_id character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    ip_address character varying(255),
    created_by character varying(24),
    grant_type smallint DEFAULT 1
);


--
-- Name: agreement_group; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.agreement_group (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    created_staff_id character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    name character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone NOT NULL,
    deleted_by character varying(24) NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: agreement_group_member; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.agreement_group_member (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    group_id character varying(24) NOT NULL,
    created_staff_id character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    staff_user_id character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: appeal_forms; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.appeal_forms (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    names jsonb NOT NULL,
    code_value smallint NOT NULL,
    parent_id character varying(24) NOT NULL,
    type smallint NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_by character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: appeal_incoming_place; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.appeal_incoming_place (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    names jsonb NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    type smallint NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: apps; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.apps (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    link character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_by character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: auth_keys; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.auth_keys (
    id character varying(255) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: content_template; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.content_template (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    created_by character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_by character varying(255),
    deleted_at timestamp with time zone,
    content jsonb,
    type smallint DEFAULT '1'::smallint
);


--
-- Name: corrector; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.corrector (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    staff_id character varying(24) NOT NULL,
    director_staff_id character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: country; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.country (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    code character varying(3) NOT NULL,
    name_en character varying(255) NOT NULL,
    name jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name_ru character varying(255) NOT NULL,
    name_uz character varying(255) NOT NULL,
    name_uz_cryl character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: delivery_type; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.delivery_type (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24),
    db_id character varying(24),
    name jsonb NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: delivery_type_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.delivery_type_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: departments; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.departments (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    name_uz character varying(32) NOT NULL,
    name_ru character varying(32) NOT NULL,
    name_qqr character varying(32) NOT NULL,
    name_uz_cryl character varying(32) NOT NULL,
    chief_user_id character varying(24) NOT NULL,
    parent_id character varying(24),
    parent_hierarchy public.ltree,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    sequence_index text
);


--
-- Name: deputy_senator_request_documents; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.deputy_senator_request_documents (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying(24) NOT NULL,
    db_id character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24),
    is_deleted boolean DEFAULT false NOT NULL,
    type_id character varying(24) NOT NULL,
    subjects_id character varying(24) NOT NULL,
    subjects_id_json jsonb
);


--
-- Name: directly_sent_docs; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.directly_sent_docs (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying(24) NOT NULL,
    recipient_staff_id character varying(24) NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    action bigint NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    comment character varying(255) NOT NULL,
    document_year smallint NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: document_agreement; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_agreement (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    recipient_user_id character varying(24) NOT NULL,
    agreement_type character varying(32) NOT NULL,
    brief_content character varying(255),
    is_deleted boolean DEFAULT false NOT NULL,
    files jsonb,
    agreement_at timestamp with time zone,
    type smallint DEFAULT '1'::smallint NOT NULL,
    "order" smallint NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    document_year smallint NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    active smallint DEFAULT 1 NOT NULL
);


--
-- Name: document_agreement_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_agreement_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_appeal; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_appeal (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    type_id character varying(24) NOT NULL,
    country_id character varying(24) NOT NULL,
    region_id character varying(24) NOT NULL,
    district_id character varying(24) NOT NULL,
    subjects_id character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    retrying_type smallint NOT NULL,
    sender_number character varying(100) NOT NULL,
    appeal_number character varying(100) NOT NULL,
    appeal_type smallint NOT NULL,
    journal_id character varying(24) NOT NULL,
    incoming_place character varying(24) NOT NULL,
    sender_date date NOT NULL,
    legal smallint DEFAULT '0'::smallint NOT NULL,
    legal_db_name character varying(255) NOT NULL,
    is_urgently boolean DEFAULT false NOT NULL,
    is_secret boolean DEFAULT false NOT NULL,
    sender_db_id character varying(24) NOT NULL,
    signed_by_id character varying(24) NOT NULL,
    signed_by_json jsonb NOT NULL,
    address character varying(255) NOT NULL,
    brief_content character varying(255) NOT NULL,
    page bigint NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    high_standing_task character varying(255) NOT NULL,
    appeal_category smallint NOT NULL,
    recipient_chief_id character varying(24) NOT NULL,
    recipient_staff_id character varying(24) NOT NULL,
    delivery_info jsonb NOT NULL,
    citizen_result jsonb NOT NULL,
    due_date date NOT NULL,
    incoming_document_id character varying(24) NOT NULL,
    gender bigint NOT NULL,
    citizen bigint NOT NULL,
    info jsonb NOT NULL,
    call_centre jsonb NOT NULL,
    first_subject_id character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    parent_subject_id character varying(24) NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    document_year smallint NOT NULL
);


--
-- Name: document_business_trip; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_business_trip (
    id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24) NOT NULL,
    db_id character varying(24),
    department_id character varying(24),
    address character varying(255),
    from_date date NOT NULL,
    to_date date NOT NULL,
    document_id character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false,
    base character varying(255),
    extended_date date,
    arrival_date date,
    status smallint DEFAULT '0'::smallint,
    signer_user_ids character varying(24)[] DEFAULT '{}'::character varying[],
    document_year integer
);


--
-- Name: document_business_trip_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_business_trip_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_files_version; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_files_version (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    document_id character varying(24) NOT NULL,
    file_id character varying(24) NOT NULL,
    action smallint NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: document_flow; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_flow (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24),
    db_id character varying(24),
    parent_id character varying(24),
    document_id character varying(24) NOT NULL,
    document_parent_hierarchy character varying(255),
    task_id character varying(24),
    task_parent_hierarchy character varying(255),
    type smallint NOT NULL,
    recipient_id character varying(24),
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_by character varying(24),
    deleted_at timestamp with time zone,
    recipient_db_id character varying(24),
    contents character varying(255),
    document_year smallint,
    document_parent_hierarchy_arr character varying[] GENERATED ALWAYS AS (
CASE
    WHEN (document_parent_hierarchy IS NOT NULL) THEN string_to_array((document_parent_hierarchy)::text, '.'::text)
    ELSE NULL::text[]
END) STORED,
    recipient_user_id character varying(24),
    controller_id character varying(24),
    document_send_id character varying(24)
);


--
-- Name: document_numbers; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_numbers (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    department_id character varying(24) NOT NULL,
    template character varying(32) NOT NULL,
    last_number bigint NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    year bigint NOT NULL,
    category character varying(20) NOT NULL
);


--
-- Name: document_outgoing; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_outgoing (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    sender_db_id character varying(24),
    sender_department_id character varying(24),
    sender_user_id character varying(24),
    recipient_db_id character varying(24),
    status smallint DEFAULT '0'::smallint NOT NULL,
    document_id character varying(24) NOT NULL,
    active smallint DEFAULT '1'::smallint NOT NULL,
    document_year smallint NOT NULL,
    response_document_id character varying(24),
    response_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    db_id character varying NOT NULL,
    delivery_type_id character varying(250),
    copy_code character varying,
    copy_file jsonb,
    registried_by character varying(255)
);


--
-- Name: document_outgoing_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_outgoing_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_permissions; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_permissions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    department_id character varying(24) NOT NULL,
    user_id character varying(24) NOT NULL,
    staff_id character varying(24) NOT NULL,
    created_by character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    perm_type character varying(255) NOT NULL,
    document_year smallint NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: document_qr_code; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_qr_code (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying(24) NOT NULL,
    file_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    archive boolean DEFAULT false NOT NULL,
    document_year smallint NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: document_read_logs; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_read_logs (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    read_at timestamp with time zone DEFAULT now(),
    read_by character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL
);


--
-- Name: document_receiver_groups_for_send_sign; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_receiver_groups_for_send_sign (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    name text NOT NULL,
    chief_ids text[] DEFAULT '{}'::text[]
);


--
-- Name: document_receiver_groups_for_send_sign_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_receiver_groups_for_send_sign_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_send; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_send (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    recipient_user_id character varying(24),
    status smallint DEFAULT 0 NOT NULL,
    is_done boolean DEFAULT false,
    is_deleted boolean DEFAULT false NOT NULL,
    action_at timestamp with time zone,
    action_by character varying(24),
    db_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    has_draft boolean DEFAULT false NOT NULL,
    template_file json,
    fishka_file json,
    reject_info jsonb,
    created_year smallint NOT NULL,
    created_date date DEFAULT CURRENT_DATE NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    secret_type character varying(50) DEFAULT 'SIMPLE'::character varying NOT NULL,
    document_year smallint NOT NULL,
    read_at timestamp with time zone,
    content character varying(255),
    doc_main_file json NOT NULL,
    doc_attachment_files jsonb,
    deleted_by character varying,
    deleted_at timestamp with time zone,
    is_main boolean DEFAULT false,
    parent_task_id character varying(24) DEFAULT NULL::character varying,
    recipient_department_id character varying(255),
    doc_signer_id character varying(24),
    type character varying GENERATED ALWAYS AS (
CASE
    WHEN (recipient_user_id IS NULL) THEN 'EXTERNAL'::text
    ELSE 'INTERNAL'::text
END) STORED,
    template_file_id character varying(24),
    doc_signer_org_id character varying(24),
    cancel_info character varying(255),
    reviewed_at timestamp with time zone
);


--
-- Name: COLUMN document_send.status; Type: COMMENT; Schema: archive; Owner: -
--

COMMENT ON COLUMN archive.document_send.status IS '0 - new, 5 - sent_to_chief, 10 - read, 20 - rejected, 30 - signed';


--
-- Name: document_send_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_send_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_send_signature; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_send_signature (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    document_send_id character varying(24) NOT NULL,
    hash text,
    is_deleted boolean DEFAULT false NOT NULL,
    output_file_id character varying(24) NOT NULL,
    details jsonb NOT NULL,
    pkcs7 text,
    status smallint DEFAULT '1'::smallint NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    document_year smallint,
    created_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    document_id character varying(24),
    is_active boolean DEFAULT true
);


--
-- Name: document_send_signature_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_send_signature_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_signers; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_signers (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    org_id character varying(24),
    phone_number character varying(255),
    user_id character varying(24),
    "position" text,
    is_deleted boolean DEFAULT false,
    deleted_by character varying(24),
    full_name text,
    type integer GENERATED ALWAYS AS (
CASE
    WHEN (user_id IS NOT NULL) THEN 2
    ELSE 1
END) STORED
);


--
-- Name: document_subject; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_subject (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    name jsonb NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    parent_id character varying(24),
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    document_type_id character varying(24),
    department_ids character varying(24)[]
);


--
-- Name: document_subject_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_subject_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_types; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.document_types (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    name_uz character varying(32) NOT NULL,
    name_ru character varying(32) NOT NULL,
    name_qqr character varying(32) NOT NULL,
    name_uz_latin character varying(32) NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: documents; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.documents (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    type_id character varying(24) NOT NULL,
    brief_content_krill character varying(255),
    document_name character varying(255) NOT NULL,
    document_number character varying(32) NOT NULL,
    document_date date NOT NULL,
    main_file jsonb NOT NULL,
    parent_document_id character varying(24),
    journal_id character varying(24),
    parent_hierarchy public.ltree,
    due_date date,
    status smallint DEFAULT 1 NOT NULL,
    is_done boolean DEFAULT false,
    registration_number character varying(100),
    deleted_by character varying(24),
    deleted_at timestamp with time zone,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    attachments jsonb[],
    is_active boolean DEFAULT true NOT NULL,
    year bigint NOT NULL,
    label_ids character varying(255),
    secret_type public.document_secret_type DEFAULT 'SIMPLE'::public.document_secret_type NOT NULL,
    internal_doc_type_id character varying(24),
    updated_at timestamp with time zone,
    lang character varying(25),
    comment character varying(255),
    list_count smallint,
    attachment_count smallint,
    attachment_list_count smallint,
    is_controlled boolean DEFAULT false,
    additional_signers character varying[],
    main_signer_id character varying(24),
    main_signer_db_id character varying(24),
    brief_content_uz_latn text,
    brief_content_ru text,
    subject_id character varying(24),
    auto_reg_generate boolean DEFAULT false,
    is_published boolean DEFAULT false,
    custom_input text
);


--
-- Name: documents_count; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.documents_count (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    created_by character varying(24) NOT NULL,
    type_id character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    year smallint NOT NULL,
    total_count bigint NOT NULL,
    internal_doc_type_id character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: docx_file_annotations; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.docx_file_annotations (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    file_id character varying(24) NOT NULL,
    annotation text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(24)
);


--
-- Name: download_logs; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.download_logs (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    user_id character varying(24),
    download_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    file_id character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: draft_agreements; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.draft_agreements (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying(24) NOT NULL,
    recipient_user_id character varying(24) NOT NULL,
    "order" bigint NOT NULL,
    recipient_user_json jsonb NOT NULL,
    created_by character varying(24),
    db_id character varying(36) NOT NULL,
    document_year smallint NOT NULL
);


--
-- Name: drawing_journal_number_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.drawing_journal_number_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    type character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    new_value text NOT NULL,
    old_value text NOT NULL,
    main_id character varying(255),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: drawing_journal_number_gen; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.drawing_journal_number_gen (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    classification smallint DEFAULT '5'::smallint NOT NULL,
    drawing jsonb NOT NULL,
    department_id character varying(24) NOT NULL,
    sign_user_id character varying(24) NOT NULL,
    work_user_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    doc_type_id character varying(24) NOT NULL,
    journal_id character varying(24) NOT NULL,
    journal_json jsonb NOT NULL
);


--
-- Name: execution_control_tabs; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.execution_control_tabs (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    name text NOT NULL,
    document_type_ids text[] DEFAULT '{}'::text[],
    internal_doc_type_ids text[] DEFAULT '{}'::text[]
);


--
-- Name: failed_logs; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.failed_logs (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    table_name character varying(64) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    kafka_message json,
    retry_count smallint DEFAULT '0'::smallint NOT NULL,
    error_message text,
    is_migrated boolean DEFAULT false NOT NULL,
    service character varying
);


--
-- Name: favorite_organizations; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.favorite_organizations (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    user_id character varying(24) NOT NULL,
    department_id character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    favorite_db_id character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: favorite_tasks; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.favorite_tasks (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    recipient_id character varying(24) NOT NULL,
    task_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    document_year smallint NOT NULL,
    db_id character varying(24) NOT NULL
);


--
-- Name: file_host; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.file_host (
    id smallint NOT NULL,
    name character varying(30) NOT NULL,
    description character varying(255),
    is_archived boolean,
    details jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: files; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.files (
    id character varying(24) NOT NULL,
    db_id character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24),
    is_deleted boolean DEFAULT false,
    type character varying(255),
    name character varying(255),
    size integer,
    content_size integer,
    is_private boolean DEFAULT false,
    file_host_id smallint DEFAULT '1'::smallint,
    hash character varying(255),
    last_modified timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    info jsonb
);


--
-- Name: fraction_members; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.fraction_members (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    director_user_id character varying(24),
    is_deleted boolean DEFAULT false NOT NULL,
    type character varying(16),
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    name_uz character varying(256)
);


--
-- Name: generate_journal_number; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.generate_journal_number (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    journal_id character varying(24) NOT NULL,
    seq_number bigint NOT NULL,
    date_row date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    year bigint NOT NULL
);


--
-- Name: generate_journal_number_change; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.generate_journal_number_change (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24),
    created_by_json jsonb,
    journal_id character varying(24),
    generate_journal_number_id character varying(24),
    old_value jsonb,
    new_value jsonb,
    action character varying(50)
);


--
-- Name: generate_journal_number_list; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.generate_journal_number_list (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    journal_number_id character varying(24) NOT NULL,
    document_id character varying(24),
    seq_number bigint NOT NULL,
    generate_draw_way character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24),
    db_id character varying(24),
    journal_id character varying(24),
    draw_way jsonb NOT NULL,
    document_year smallint
);


--
-- Name: incoming_document_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.incoming_document_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: incoming_documents; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.incoming_documents (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24),
    sender_number character varying(255),
    sender_date date,
    delivery_type_id character varying(24),
    is_deleted boolean DEFAULT false,
    document_id character varying(255) NOT NULL
);


--
-- Name: COLUMN incoming_documents.sender_number; Type: COMMENT; Schema: archive; Owner: -
--

COMMENT ON COLUMN archive.incoming_documents.sender_number IS 'Kirish raqami';


--
-- Name: COLUMN incoming_documents.sender_date; Type: COMMENT; Schema: archive; Owner: -
--

COMMENT ON COLUMN archive.incoming_documents.sender_date IS 'Kirish sanasi';


--
-- Name: COLUMN incoming_documents.delivery_type_id; Type: COMMENT; Schema: archive; Owner: -
--

COMMENT ON COLUMN archive.incoming_documents.delivery_type_id IS 'Yetkazib berish turi';


--
-- Name: inner_document_type; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.inner_document_type (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name_uz character varying(255) NOT NULL,
    name_ru character varying(255) NOT NULL,
    name_uz_lat character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false,
    department_id character varying(24) NOT NULL,
    type character varying(255) NOT NULL,
    sender_organization_id character varying(24) NOT NULL,
    due_day bigint NOT NULL,
    classifications bigint NOT NULL,
    info jsonb NOT NULL
);


--
-- Name: internal_doc_type_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.internal_doc_type_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: internal_doc_types; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.internal_doc_types (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    name_json jsonb NOT NULL,
    parent_doc_type_id character varying(24) NOT NULL,
    created_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: internal_document_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.internal_document_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: internal_documents; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.internal_documents (
    id character varying(255) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false,
    deleted_at timestamp with time zone,
    deleted_by character varying(255),
    document_id character varying(255) NOT NULL,
    recipient_user_ids character varying(24)[] DEFAULT '{}'::character varying[] NOT NULL,
    signer_user_ids character varying(24)[] DEFAULT '{}'::character varying[] NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    sender_department_id character varying(255),
    sender_user_id character varying(255),
    registried_by character varying(255)
);


--
-- Name: journal; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.journal (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    name jsonb NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    prefix character varying(100),
    updated_at timestamp with time zone,
    created_date date DEFAULT CURRENT_TIMESTAMP,
    doc_type_id character varying(255)
);


--
-- Name: journal_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.journal_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: kafka_processes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.kafka_processes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    topic text,
    data jsonb,
    status character varying(255),
    error text,
    done_retries smallint DEFAULT 1,
    max_retries smallint DEFAULT 5
);


--
-- Name: knex_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knex_migrations (
    id integer NOT NULL,
    name character varying(255),
    batch integer,
    migration_time timestamp with time zone
);


--
-- Name: knex_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knex_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knex_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knex_migrations_id_seq OWNED BY public.knex_migrations.id;


--
-- Name: knex_migrations; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.knex_migrations (
    id integer DEFAULT nextval('public.knex_migrations_id_seq'::regclass) NOT NULL,
    name character varying(255),
    batch integer,
    migration_time timestamp with time zone
);


--
-- Name: knex_migrations_lock; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knex_migrations_lock (
    index integer NOT NULL,
    is_locked integer
);


--
-- Name: knex_migrations_lock_index_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.knex_migrations_lock_index_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knex_migrations_lock_index_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knex_migrations_lock_index_seq OWNED BY public.knex_migrations_lock.index;


--
-- Name: knex_migrations_lock; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.knex_migrations_lock (
    index integer DEFAULT nextval('public.knex_migrations_lock_index_seq'::regclass) NOT NULL,
    is_locked integer
);


--
-- Name: kpi_failed_transactions; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.kpi_failed_transactions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24),
    db_id character varying(36),
    kpi_data jsonb NOT NULL,
    user_id character varying(24) NOT NULL,
    status smallint DEFAULT '1'::smallint,
    error character varying(255)
);


--
-- Name: kpi_transactions; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.kpi_transactions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    task_id character varying(24) NOT NULL,
    recipient_id character varying(24) NOT NULL,
    send_action_id character varying(24) NOT NULL,
    point character varying(255) NOT NULL,
    department_id character varying(24) NOT NULL,
    user_id character varying(24) NOT NULL,
    type smallint NOT NULL,
    log jsonb NOT NULL,
    bonus_point character varying(255) DEFAULT '0'::character varying NOT NULL,
    request_id character varying(24) NOT NULL,
    document_year smallint NOT NULL
);


--
-- Name: labels; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.labels (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name character varying(255) NOT NULL,
    text_color character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    updated_by character varying(24),
    updated_at timestamp with time zone,
    db_id character varying(24),
    deleted_at timestamp with time zone,
    deleted_by character varying(24),
    bg_color character varying(255),
    type integer DEFAULT 1
);


--
-- Name: linked_document; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.linked_document (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying(24) NOT NULL,
    linked_document_id character varying(24) NOT NULL,
    document_year smallint NOT NULL
);


--
-- Name: members; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.members (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    user_id character varying(24) NOT NULL
);


--
-- Name: newspapers; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.newspapers (
    id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24) NOT NULL,
    name character varying(255),
    db_id character varying(24),
    file_id character varying(255) NOT NULL,
    files jsonb NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: normative_document_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.normative_document_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: normative_documents; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.normative_documents (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24),
    db_id character varying(36),
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    deleted_by character varying(24),
    document_id character varying(24) NOT NULL,
    validity_loss text,
    changes_made character varying(255),
    sender_department_id character varying(255),
    sender_user_id character varying(255)
);


--
-- Name: normative_legal_docs_tasks; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.normative_legal_docs_tasks (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24),
    db_id character varying(24),
    recipient_user_id character varying(24) NOT NULL,
    recipient_db_id character varying(24),
    name character varying(255),
    type smallint,
    due_date date,
    status smallint,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_by character varying(24),
    deleted_at timestamp with time zone,
    last_updated_by character varying(24),
    last_updated_at timestamp with time zone
);


--
-- Name: notifications; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.notifications (
    id character varying(255) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying(255) NOT NULL,
    task_id character varying(255),
    message text NOT NULL,
    created_by character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    recipient_user_id character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    task_due_date timestamp with time zone,
    read_at timestamp with time zone,
    is_read boolean DEFAULT false,
    is_deleted boolean DEFAULT false,
    deleted_at timestamp with time zone,
    deleted_by character varying(255),
    task_recipient_id character varying(255),
    payload text
);


--
-- Name: org_connection_type; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.org_connection_type (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    type smallint DEFAULT '1'::smallint NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL
);


--
-- Name: org_contact; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.org_contact (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    org_id character varying(24) NOT NULL,
    name jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    group_id character varying(24)
);


--
-- Name: organization_chief; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.organization_chief (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    user_id character varying(24) NOT NULL,
    can_sign boolean DEFAULT false NOT NULL,
    can_resolution boolean DEFAULT false NOT NULL,
    department_id character varying(24),
    can_decontrol boolean DEFAULT false NOT NULL,
    chief_level smallint DEFAULT '0'::smallint NOT NULL,
    seen_on_leader_board boolean DEFAULT false NOT NULL
);


--
-- Name: organization_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_types (
    id character varying(36) NOT NULL,
    db_id character varying(36),
    created_at timestamp with time zone DEFAULT now(),
    created_by character varying(36),
    is_deleted boolean DEFAULT false,
    name_ru character varying(255),
    name_uz character varying(255),
    "order" integer,
    group_id character varying(24),
    id_by_bit_length smallint NOT NULL,
    id_by_bit_str character varying GENERATED ALWAYS AS (lpad(rpad('1'::text, (id_by_bit_length)::integer, '0'::text), 128, '0'::text)) STORED
);


--
-- Name: organization_types_id_by_bit_length_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organization_types_id_by_bit_length_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_types_id_by_bit_length_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organization_types_id_by_bit_length_seq OWNED BY public.organization_types.id_by_bit_length;


--
-- Name: organization_types; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.organization_types (
    id character varying(36) NOT NULL,
    db_id character varying(36),
    created_at timestamp with time zone DEFAULT now(),
    created_by character varying(36),
    is_deleted boolean DEFAULT false,
    name_ru character varying(255),
    name_uz character varying(255),
    "order" integer,
    group_id character varying(24),
    id_by_bit_length smallint DEFAULT nextval('public.organization_types_id_by_bit_length_seq'::regclass) NOT NULL,
    id_by_bit_str character varying GENERATED ALWAYS AS (lpad(rpad('1'::text, (id_by_bit_length)::integer, '0'::text), 128, '0'::text)) STORED
);


--
-- Name: organization_weekends; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.organization_weekends (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    weekends bigint NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    updated_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    year smallint NOT NULL
);


--
-- Name: organizations; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.organizations (
    id character varying(36) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(36),
    created_at timestamp with time zone DEFAULT now(),
    created_by character varying(36),
    is_deleted boolean DEFAULT false,
    region_id character varying(36),
    type_id character varying(36),
    name_ru character varying(255),
    name_uz_cyrl character varying(255),
    address character varying(255),
    phone character varying(255),
    tin character varying(9),
    parent_id character varying(36),
    location_type character varying(255),
    relevance_type character varying(255),
    "order" integer,
    short_name_uz character varying(255),
    short_name_ru character varying(255),
    level integer,
    region_parent_id character varying(255),
    district_id character varying(24),
    prefix character varying(10),
    parent_hierarchy public.ltree,
    name_json jsonb,
    name_uz character varying(255),
    name_qqr character varying(255),
    updated_at timestamp with time zone
);


--
-- Name: organizations_1; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.organizations_1 (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_by character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name_uz character varying(255) NOT NULL,
    name_ru character varying(255),
    name_uz_cyrl character varying(255),
    name_qqr character varying(225),
    region_id character varying(24),
    district_id character varying(24),
    parent_id character varying(24),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: organizations_2; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.organizations_2 (
    id character varying(36) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(36),
    created_at timestamp with time zone DEFAULT now(),
    created_by character varying(36),
    is_deleted boolean DEFAULT false,
    region_id character varying(36),
    name_ru character varying(255),
    name_uz_cyrl character varying(255),
    parent_id character varying(36),
    relevance_type character varying(255),
    "order" integer,
    short_name_uz character varying(255),
    short_name_ru character varying(255),
    level integer,
    region_parent_id character varying(255),
    sequence_index character varying(255),
    org_level_id character varying(24),
    district_id character varying(24),
    prefix character varying(10),
    parent_hierarchy public.ltree,
    name_json jsonb,
    name_uz character varying(255),
    name_qqr character varying(255),
    updated_at timestamp with time zone
);


--
-- Name: permissions; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.permissions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    worker_user_id character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    department_id character varying(24),
    user_id character varying(24),
    permission_type bigint NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    control_type smallint NOT NULL,
    updated_at timestamp with time zone
);


--
-- Name: pkcs10_until_confirm; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.pkcs10_until_confirm (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    pkcs10 text NOT NULL,
    status smallint DEFAULT '0'::smallint NOT NULL,
    action_at timestamp with time zone,
    action_content text,
    subject jsonb NOT NULL,
    code character varying(10),
    state smallint DEFAULT '0'::smallint NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    key_algorithm public.key_algorithm NOT NULL,
    key_algorithm_version public.key_algorithm_version NOT NULL,
    confirmed_by_pkcs7 text,
    confirmed_by_certificate jsonb,
    form smallint NOT NULL,
    meth public.meth NOT NULL,
    path character varying(50),
    subj_user_id character varying(24),
    subj_org_id character varying(24),
    created_by character varying(24),
    created_by_json jsonb,
    is_deleted boolean DEFAULT false,
    pinpp character varying(14)
);


--
-- Name: positions; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.positions (
    id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by character varying(24),
    is_deleted boolean DEFAULT false,
    name_uz character varying(255),
    name_ru character varying(255),
    name_uz_cryl character varying(255),
    code character varying(255),
    name_json jsonb
);


--
-- Name: public_holidays; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.public_holidays (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    on_date date NOT NULL,
    title character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    server_id smallint NOT NULL,
    updated_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    year smallint NOT NULL
);


--
-- Name: published_doc_group_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.published_doc_group_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT now(),
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24) NOT NULL,
    action character varying,
    key_name character varying
);


--
-- Name: published_document_groups; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.published_document_groups (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by character varying(24),
    name jsonb,
    parent_id character varying(24),
    is_deleted boolean DEFAULT false,
    parent_hierarchy public.ltree,
    internal_doc_type_ids character varying(24)[]
);


--
-- Name: read_logs; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.read_logs (
    id character varying(24) NOT NULL,
    read_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    read_by character varying(24) NOT NULL,
    main_id character varying(255),
    type smallint
);


--
-- Name: recipient_answer_actions; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.recipient_answer_actions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    sender_db_id character varying(24) NOT NULL,
    sender_user_id character varying(24) NOT NULL,
    recipient_db_id character varying(24) NOT NULL,
    recipient_user_id character varying(24) NOT NULL,
    recipient_department_id character varying(24),
    task_id character varying(24) NOT NULL,
    recipient_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    active smallint DEFAULT '1'::smallint NOT NULL,
    state smallint DEFAULT '1'::smallint NOT NULL,
    contents character varying(255) NOT NULL,
    files jsonb,
    action smallint NOT NULL,
    date_row date DEFAULT CURRENT_TIMESTAMP,
    deleted_by character varying(24),
    deleted_at timestamp with time zone,
    sender_department_id character varying(24),
    parent_send boolean DEFAULT false,
    copy_from_id character varying(24),
    info jsonb,
    updated_at timestamp with time zone,
    document_year smallint,
    document_send_id character varying(24),
    parent_id character varying(24),
    answer_document_id character varying(24)
);


--
-- Name: recipient_answer_draft_until_sign; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.recipient_answer_draft_until_sign (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    document_year smallint NOT NULL,
    task_id character varying(24) NOT NULL,
    recipient_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    answer_document_id character varying(24)
);


--
-- Name: recipient_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.recipient_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: recipient_orgs_group; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.recipient_orgs_group (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    member_orgs character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone NOT NULL,
    deleted_by character varying(24) NOT NULL,
    updated_by character varying(24) NOT NULL,
    type bigint DEFAULT '1'::bigint NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: recipients_group; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.recipients_group (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    member_users character varying(24) NOT NULL,
    name character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone NOT NULL,
    deleted_by character varying(24) NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: regions; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.regions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24),
    hierarchy_key character varying(255),
    parent_id character varying(255),
    name_ru character varying(255) NOT NULL,
    name_uz character varying(255) NOT NULL,
    name_uz_cryl character varying(255) NOT NULL,
    soato character varying(7),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: reject_for_sign; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.reject_for_sign (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    content character varying(2000) NOT NULL,
    document_id character varying(24) NOT NULL,
    document_year smallint NOT NULL,
    updated_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: repeatable_plan; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.repeatable_plan (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    type character varying(100) NOT NULL,
    repetitions_count bigint NOT NULL,
    repetitions_date character varying(50) NOT NULL,
    frequency character varying(50) NOT NULL,
    start_at date NOT NULL,
    end_at date NOT NULL,
    first_task_id character varying(24) NOT NULL,
    details jsonb NOT NULL,
    document_id character varying(24) NOT NULL,
    document_year smallint NOT NULL,
    updated_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: repeatable_plan_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.repeatable_plan_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    created_by_json jsonb NOT NULL,
    plan_id character varying(24) NOT NULL,
    old_value jsonb NOT NULL,
    new_value jsonb NOT NULL,
    actions character varying(24) NOT NULL
);


--
-- Name: repeatable_task; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.repeatable_task (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    due_date date NOT NULL,
    plan_id character varying(24) NOT NULL,
    activation_date date NOT NULL,
    active_task_id character varying(24) NOT NULL,
    status character varying(100) NOT NULL,
    document_id character varying(24) NOT NULL,
    document_year smallint NOT NULL,
    updated_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: repeatable_task_cron; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.repeatable_task_cron (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    status character varying(50) NOT NULL,
    document_year smallint NOT NULL,
    updated_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: request_draft_until_sign; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.request_draft_until_sign (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying(24) NOT NULL,
    request jsonb NOT NULL,
    send jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    document_year smallint NOT NULL,
    task_id character varying(24) NOT NULL,
    recipient_id character varying(24) NOT NULL
);


--
-- Name: resolution_template; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.resolution_template (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    file_id character varying(24) NOT NULL,
    db_id character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24),
    title character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    header_file_id character varying(24) NOT NULL,
    updated_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    document_type_id character varying(24),
    version smallint DEFAULT 1
);


--
-- Name: resolution_template_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.resolution_template_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: role_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.role_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value jsonb,
    old_value jsonb,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: role_permission_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.role_permission_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value jsonb,
    old_value jsonb,
    main_id character varying(24) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: role_permission_list; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.role_permission_list (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    name character varying(255),
    code character varying(255),
    parent_id character varying(24),
    table_name character varying(255),
    parent_hierarchy public.ltree,
    type character varying(255),
    required_filters jsonb
);


--
-- Name: role_permissions; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.role_permissions (
    id character varying(24) NOT NULL,
    role_id character varying(255),
    permission_id character varying(24),
    condition_sql text DEFAULT '1=1'::text,
    condition_code jsonb,
    is_deleted boolean DEFAULT false
);


--
-- Name: roles; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.roles (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name character varying(255),
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    deleted_by character varying(255),
    deleted_at timestamp with time zone
);


--
-- Name: senate_committee_members; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.senate_committee_members (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    type character varying(16),
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    name_uz character varying(256),
    user_id character varying(24) NOT NULL,
    director_user_id character varying(24)
);


--
-- Name: send_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.send_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    send_id character varying(24) NOT NULL,
    recipient_id character varying(24) NOT NULL,
    task_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    old_value jsonb NOT NULL,
    new_value jsonb NOT NULL,
    change_value jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    created_by_json jsonb NOT NULL,
    document_year smallint NOT NULL
);


--
-- Name: send_to_child_access; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.send_to_child_access (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    user_id character varying(24) NOT NULL
);


--
-- Name: task_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.task_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24) NOT NULL,
    action character varying(255),
    key_name character varying(255),
    content character varying(255),
    files jsonb
);


--
-- Name: task_content_templates; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.task_content_templates (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24),
    name_uz character varying(255) NOT NULL,
    name_ru character varying(255) NOT NULL,
    name_uz_lat character varying(255) NOT NULL,
    department_id character varying(24),
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: task_controllers; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.task_controllers (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    db_id character varying(24) NOT NULL,
    controller_user_id character varying(24) NOT NULL,
    controller_department_id character varying(24) NOT NULL,
    controller_db_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    task_id character varying(24) NOT NULL,
    updated_at timestamp with time zone,
    updated_by character varying(24),
    deleted_by character varying(24),
    deleted_at timestamp with time zone,
    is_deleted boolean DEFAULT false NOT NULL,
    document_year smallint NOT NULL,
    read_at timestamp with time zone
);


--
-- Name: task_draft_until_sign; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.task_draft_until_sign (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying(24) NOT NULL,
    tasks jsonb NOT NULL,
    created_by character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    db_id character varying(24) NOT NULL,
    document_year smallint NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    document_send_id character varying(24),
    controllers jsonb,
    related_tasks jsonb,
    recipients jsonb NOT NULL,
    is_deleted boolean DEFAULT false,
    view jsonb
);


--
-- Name: task_recipients; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.task_recipients (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    recipient_department_id character varying(24),
    recipient_db_id character varying(24) NOT NULL,
    status bigint DEFAULT '0'::bigint NOT NULL,
    done_by character varying(24),
    done_at timestamp with time zone,
    document_id character varying(24) NOT NULL,
    task_id character varying(24) NOT NULL,
    is_main boolean DEFAULT false NOT NULL,
    is_done boolean DEFAULT false,
    db_id character varying(24) NOT NULL,
    deleted_by character varying(24),
    deleted_at timestamp with time zone,
    recipient_user_id character varying(24) NOT NULL,
    updated_by character varying(24),
    updated_at timestamp with time zone,
    parent_id character varying(24),
    type smallint DEFAULT 1 NOT NULL,
    sender_user_id character varying(24) NOT NULL,
    sequence smallint,
    equally_strong smallint DEFAULT 0 NOT NULL,
    document_year smallint NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    read_at timestamp with time zone,
    document_send_id character varying(24),
    sender_department_id character varying(24),
    parent_hierarchy public.ltree,
    sender_db_id character varying(24),
    recipient_user_json jsonb GENERATED ALWAYS AS (public.get_user_by_id_json(recipient_user_id)) STORED
);


--
-- Name: task_recipients_count; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.task_recipients_count (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_date date NOT NULL,
    document_type_id character varying(24) NOT NULL,
    sender_db_id character varying(24) NOT NULL,
    sender_department_id character varying(24) NOT NULL,
    sender_user_id character varying(24) NOT NULL,
    recipient_db_id character varying(24) NOT NULL,
    recipient_department_id character varying(24) DEFAULT '0character'::character varying NOT NULL,
    recipient_user_id character varying(24) DEFAULT '0character'::character varying NOT NULL,
    status bigint NOT NULL,
    total_count bigint DEFAULT '0'::bigint NOT NULL,
    type smallint DEFAULT '1'::smallint NOT NULL,
    is_main boolean DEFAULT false NOT NULL,
    document_year bigint NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    internal_doc_type_id character varying(24) DEFAULT '0character'::character varying NOT NULL
);


--
-- Name: task_requests; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.task_requests (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    contents character varying(255) NOT NULL,
    files jsonb,
    db_id character varying(24) NOT NULL,
    recipient_id character varying(24) NOT NULL,
    task_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    deleted_by character varying(24),
    deleted_at timestamp with time zone,
    request_document_id character varying(24),
    copy_from_id character varying(24),
    updated_at timestamp with time zone,
    document_year smallint,
    document_send_id character varying(24)
);


--
-- Name: tasks; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.tasks (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    due_date date,
    is_deleted boolean DEFAULT false NOT NULL,
    is_done boolean DEFAULT false NOT NULL,
    done_at timestamp with time zone,
    done_by character varying(24),
    db_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    content character varying(255),
    sender_user_id character varying(24),
    parent_id character varying(24),
    pa_task_id character varying(24),
    deleted_by character varying(24),
    deleted_at timestamp with time zone,
    sender_department_id character varying(24),
    type smallint DEFAULT '1'::smallint NOT NULL,
    label_ids character varying(24)[],
    sequence bigint,
    updated_at timestamp with time zone,
    document_year smallint,
    status smallint DEFAULT 1 NOT NULL,
    document_send_id character varying(24),
    is_controlled boolean DEFAULT false NOT NULL,
    parent_hierarchy public.ltree,
    comment character varying(255),
    commented_at date
);


--
-- Name: tasks_count; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.tasks_count (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    sender_db_id character varying(24) NOT NULL,
    sender_user_id character varying(24) NOT NULL,
    sender_department_id character varying(24) NOT NULL,
    created_date date NOT NULL,
    due_date date NOT NULL,
    is_done boolean NOT NULL,
    done_date date NOT NULL,
    type smallint NOT NULL,
    document_year smallint NOT NULL,
    total_count bigint NOT NULL,
    document_type_id character varying(24) NOT NULL,
    internal_doc_type_id character varying(24) NOT NULL
);


--
-- Name: tasks_for_sign; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.tasks_for_sign (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    db_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    sender_db_id character varying(24) NOT NULL,
    sender_department_id character varying(24) NOT NULL,
    sender_user_id character varying(24) NOT NULL,
    recipient_db_id character varying(24) NOT NULL,
    recipient_department_id character varying(24) NOT NULL,
    recipient_user_id character varying(24) NOT NULL,
    content character varying(2048) NOT NULL,
    sign_id character varying(24) NOT NULL,
    due_date date NOT NULL,
    details jsonb NOT NULL,
    status bigint DEFAULT '0'::bigint NOT NULL,
    action_at timestamp with time zone NOT NULL,
    action_by character varying(24) NOT NULL,
    reject_id character varying(24) NOT NULL,
    corrector_user_id character varying(24) NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    document_year smallint NOT NULL
);


--
-- Name: temporary_accepted_tasks; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.temporary_accepted_tasks (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    task_id character varying(255) NOT NULL,
    due_date date NOT NULL,
    content character varying(255),
    "current_user" json,
    is_deleted boolean DEFAULT false
);


--
-- Name: upper_organizations; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.upper_organizations (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    parent_org_id character varying(24) NOT NULL,
    child_org_id character varying(24) NOT NULL,
    curator_user_id character varying(24) NOT NULL,
    curator_department_id character varying(24) NOT NULL,
    updated_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: user_changes; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.user_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: user_roles; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.user_roles (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT now(),
    user_id character varying(24),
    role_id character varying(24)
);


--
-- Name: users; Type: TABLE; Schema: archive; Owner: -
--

CREATE TABLE archive.users (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    verified boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    pinpp bigint NOT NULL,
    first_name character varying(32) NOT NULL,
    last_name character varying(32) NOT NULL,
    middle_name character varying(32),
    gender character varying(24) NOT NULL,
    birthday date NOT NULL,
    username character varying(24),
    password character varying(255),
    last_auth timestamp with time zone,
    created_by character varying(24),
    db_id character varying(24) NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    department_id character varying(24),
    position_id character varying(24),
    full_name character varying GENERATED ALWAYS AS (TRIM(BOTH FROM (((((COALESCE(last_name, ''::character varying))::text || ' '::text) || (COALESCE(first_name, ''::character varying))::text) || ' '::text) || (COALESCE(middle_name, ''::character varying))::text))) STORED,
    sequence_index text,
    status smallint DEFAULT 1
);


--
-- Name: direction; Type: TABLE; Schema: president_assignments; Owner: -
--

CREATE TABLE president_assignments.direction (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name_uz character varying(200) NOT NULL,
    name_ru character varying(200) NOT NULL,
    name_uz_lat character varying(200) NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    ordering integer DEFAULT 0,
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint NOT NULL
);


--
-- Name: TABLE direction; Type: COMMENT; Schema: president_assignments; Owner: -
--

COMMENT ON TABLE president_assignments.direction IS 'Xujjat turkumlari
';


--
-- Name: document_internal_order_state; Type: TABLE; Schema: president_assignments; Owner: -
--

CREATE TABLE president_assignments.document_internal_order_state (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24),
    created_by_json jsonb NOT NULL,
    document_id character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    status integer DEFAULT 2 NOT NULL,
    internal_creator_id character varying(24),
    document_year smallint,
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint NOT NULL,
    workflow_document_id character varying(24)
);


--
-- Name: TABLE document_internal_order_state; Type: COMMENT; Schema: president_assignments; Owner: -
--

COMMENT ON TABLE president_assignments.document_internal_order_state IS 'xujjatidagi topshiriqlar ijroga qaratilmagan tashkilotlar ro''yxati\';


--
-- Name: COLUMN document_internal_order_state.status; Type: COMMENT; Schema: president_assignments; Owner: -
--

COMMENT ON COLUMN president_assignments.document_internal_order_state.status IS '0 - not created
1 - created
2 - registratsiya qilish kerak
3 - registratsiya qilingan';


--
-- Name: documents; Type: TABLE; Schema: president_assignments; Owner: -
--

CREATE TABLE president_assignments.documents (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) DEFAULT '58fb1512809c134656986d2b'::character varying NOT NULL,
    document_id character varying(24),
    brief_content text,
    details jsonb,
    document_name text,
    document_number character varying(50),
    document_date date,
    type_id character varying(24) NOT NULL,
    files jsonb,
    deleted_by character varying(24),
    created_by_json jsonb,
    deleted_by_json jsonb,
    deleted_at timestamp with time zone,
    direction_id character varying(24),
    year smallint DEFAULT date_part('year'::text, CURRENT_DATE),
    is_secret boolean DEFAULT false,
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint
);


--
-- Name: task_recipients; Type: TABLE; Schema: president_assignments; Owner: -
--

CREATE TABLE president_assignments.task_recipients (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24),
    db_id character varying(24),
    is_deleted boolean DEFAULT false NOT NULL,
    recipient_db_id character varying(24),
    recipient_user_id character varying(24),
    is_done boolean DEFAULT false,
    done_at timestamp with time zone,
    done_by character varying(24),
    is_main boolean DEFAULT false,
    status integer DEFAULT 0 NOT NULL,
    document_id character varying(24) NOT NULL,
    task_id character varying(24) NOT NULL,
    deleted_by character varying(24),
    deleted_by_json jsonb,
    deleted_at timestamp with time zone,
    delete_reason character varying(200),
    updated_at timestamp with time zone,
    updated_by character varying(24),
    first_view jsonb,
    recipient_db_json jsonb,
    recipient_user_json jsonb,
    repeatable smallint DEFAULT 0,
    equally_strong smallint DEFAULT 0,
    done_by_json jsonb,
    info jsonb,
    document_year smallint,
    read_json json,
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint
);


--
-- Name: COLUMN task_recipients.status; Type: COMMENT; Schema: president_assignments; Owner: -
--

COMMENT ON COLUMN president_assignments.task_recipients.status IS '0  - in_progress - (is_done is not true and (due_date>=current_date or due_date is null))
1  - in_progress_pending
2  - in_progress_reject
3  - in_progress_re_control
4  - in_progress_review
10 - overdue - (is_done is not true and due_date<current_date and due_date is not null)
11 - overdue_pending
12 - overdue_reject
13 - overdue_re_control
14 - overdue_review
20 - done - (is_done is true)
21 - done_overdue';


--
-- Name: COLUMN task_recipients.first_view; Type: COMMENT; Schema: president_assignments; Owner: -
--

COMMENT ON COLUMN president_assignments.task_recipients.first_view IS '{
view_at:timestamptz
view_by: varchar(24)
}';


--
-- Name: COLUMN task_recipients.equally_strong; Type: COMMENT; Schema: president_assignments; Owner: -
--

COMMENT ON COLUMN president_assignments.task_recipients.equally_strong IS '0 - 
1 - teng kuchli';


--
-- Name: task_requests; Type: TABLE; Schema: president_assignments; Owner: -
--

CREATE TABLE president_assignments.task_requests (
    id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    contents text,
    recipient_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    task_id character varying(24) NOT NULL,
    files jsonb,
    deleted_by character varying(24),
    deleted_by_json jsonb,
    deleted_at timestamp with time zone,
    created_by_json jsonb,
    period_id character varying(24),
    document_year smallint,
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint,
    request_document_id character varying(24)
);


--
-- Name: task_send; Type: TABLE; Schema: president_assignments; Owner: -
--

CREATE TABLE president_assignments.task_send (
    id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    sender_db_id character varying(24) NOT NULL,
    sender_user_id character varying(24) NOT NULL,
    recipient_db_id character varying(24),
    recipient_user_id character varying(24),
    recipient_department_id character varying(24),
    task_id character varying(24) NOT NULL,
    recipient_id character varying(24) NOT NULL,
    request_id character varying(24),
    document_id character varying(24) NOT NULL,
    active smallint DEFAULT 1 NOT NULL,
    state smallint DEFAULT 1 NOT NULL,
    contents text,
    files jsonb,
    sender_type smallint,
    date_row date DEFAULT CURRENT_DATE NOT NULL,
    created_by_json jsonb,
    sender_user_json jsonb,
    recipient_user_json jsonb,
    deleted_by character varying(24),
    deleted_by_json jsonb,
    deleted_at timestamp with time zone,
    sender_department_id character varying(24),
    info jsonb,
    period_id character varying(24),
    document_year smallint,
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint
);


--
-- Name: COLUMN task_send.active; Type: COMMENT; Schema: president_assignments; Owner: -
--

COMMENT ON COLUMN president_assignments.task_send.active IS '1 - active
0 - inactive';


--
-- Name: COLUMN task_send.state; Type: COMMENT; Schema: president_assignments; Owner: -
--

COMMENT ON COLUMN president_assignments.task_send.state IS '1  - task_send
-1 - task_reject
2  - re_controlled';


--
-- Name: COLUMN task_send.sender_type; Type: COMMENT; Schema: president_assignments; Owner: -
--

COMMENT ON COLUMN president_assignments.task_send.sender_type IS '10 - done_request
20 - minjust_approve
25 - minjust_accept
28 - minjust_recontrol
29 - minjust_reject
30 - cabmin_approve
35 - cabmin_accept
38 - cabmin_recontrol
39 - cabmin_reject
40 - ach_approve
44 - ach_review
45 - ach_accept
48 - ach_recontrol
49 - ach_reject
55 - adm_accept
58 - adm_recontrol
59 - adm_reject';


--
-- Name: tasks; Type: TABLE; Schema: president_assignments; Owner: -
--

CREATE TABLE president_assignments.tasks (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    contents text,
    is_done boolean DEFAULT false,
    due_date date,
    point_number character varying(32),
    document_id character varying(24) NOT NULL,
    done_at timestamp with time zone,
    done_by character varying(24),
    mechanism text,
    deleted_at timestamp with time zone,
    deleted_by character varying(24),
    deleted_by_json jsonb,
    details jsonb,
    repeatable smallint DEFAULT 0,
    task_code character varying(7),
    document_year smallint,
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint
);


--
-- Name: access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.access_tokens (
    id character varying(24) NOT NULL,
    access_token text NOT NULL,
    access_token_expires_on timestamp with time zone DEFAULT (now() + '18:00:00'::interval) NOT NULL,
    refresh_token text,
    refresh_token_expires_on timestamp with time zone DEFAULT (now() + '7 days'::interval),
    user_id character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    root_id character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    ip_address character varying(255),
    created_by character varying(24),
    grant_type smallint DEFAULT 1
);


--
-- Name: adm_leaders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adm_leaders (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    user_id character varying(24) NOT NULL
);


--
-- Name: agreement_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agreement_group (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    created_staff_id character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    name character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone NOT NULL,
    deleted_by character varying(24) NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: agreement_group_member; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agreement_group_member (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    group_id character varying(24) NOT NULL,
    created_staff_id character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    staff_user_id character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: ai_suggestions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ai_suggestions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    document_id character varying(24),
    file_id character varying(24),
    status smallint DEFAULT 1 NOT NULL,
    payload jsonb
);


--
-- Name: app_constants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_constants (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name character varying,
    value character varying
);


--
-- Name: assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assignments (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    staffing_position_id character varying(24) NOT NULL,
    user_id character varying(24) NOT NULL,
    is_reserve boolean DEFAULT false NOT NULL,
    started_at date DEFAULT CURRENT_DATE NOT NULL,
    ended_at date,
    is_deleted boolean DEFAULT false NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    start_order_number character varying(32),
    start_order_document_id character varying(24),
    start_attachments jsonb,
    end_order_number character varying(32),
    end_order_document_id character varying(24),
    end_attachments jsonb
);


--
-- Name: async_processor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.async_processor (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    code character varying(255) DEFAULT public.gen_async_processor_code(),
    command character varying(255) NOT NULL,
    payload json,
    status character varying(255) DEFAULT 'processing'::character varying NOT NULL,
    zip_file_id character varying(255),
    document_id character varying(255),
    error text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    created_by character varying(24) NOT NULL,
    finished_at timestamp with time zone,
    response json
);


--
-- Name: audit_cleanup_log_2026_02_11; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_cleanup_log_2026_02_11 (
    audit_id integer NOT NULL,
    target_table_name character varying(50),
    record_id character varying(24),
    parent_document_id character varying(24),
    cleanup_timestamp timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: audit_cleanup_log_2026_02_11_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_cleanup_log_2026_02_11_audit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_cleanup_log_2026_02_11_audit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_cleanup_log_2026_02_11_audit_id_seq OWNED BY public.audit_cleanup_log_2026_02_11.audit_id;


--
-- Name: auth_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_keys (
    id character varying(255) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: background_check_batches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.background_check_batches (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name character varying(255),
    total_items integer DEFAULT 0 NOT NULL,
    sync_package_id uuid,
    file_id character varying(24),
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    pending_count integer DEFAULT 0 NOT NULL,
    submitted_count integer DEFAULT 0 NOT NULL,
    processing_count integer DEFAULT 0 NOT NULL,
    completed_count integer DEFAULT 0 NOT NULL,
    failed_count integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    total integer,
    CONSTRAINT background_check_batches_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'processing'::character varying, 'completed'::character varying, 'failed'::character varying, 'partial'::character varying])::text[])))
);


--
-- Name: TABLE background_check_batches; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.background_check_batches IS 'Tracks batches of background check requests imported from CSV/ZIP files';


--
-- Name: COLUMN background_check_batches.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_check_batches.id IS 'Primary key - 24 character string ID';


--
-- Name: COLUMN background_check_batches.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_check_batches.name IS 'Optional batch name/description';


--
-- Name: COLUMN background_check_batches.total_items; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_check_batches.total_items IS 'Total number of background check requests in this batch';


--
-- Name: COLUMN background_check_batches.sync_package_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_check_batches.sync_package_id IS 'Links to sync_packages table to track the import package';


--
-- Name: COLUMN background_check_batches.file_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_check_batches.file_id IS 'Reference to the uploaded file (ZIP or CSV)';


--
-- Name: COLUMN background_check_batches.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_check_batches.status IS 'Batch processing status: pending, processing, completed, failed, partial';


--
-- Name: COLUMN background_check_batches.pending_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_check_batches.pending_count IS 'Number of requests in pending status';


--
-- Name: COLUMN background_check_batches.submitted_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_check_batches.submitted_count IS 'Number of requests in submitted status';


--
-- Name: COLUMN background_check_batches.processing_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_check_batches.processing_count IS 'Number of requests in processing status';


--
-- Name: COLUMN background_check_batches.completed_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_check_batches.completed_count IS 'Number of requests in completed status';


--
-- Name: COLUMN background_check_batches.failed_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_check_batches.failed_count IS 'Number of requests in failed status';


--
-- Name: background_checks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.background_checks (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    user_id character varying(24),
    pinpp character varying(14),
    tin character varying(20),
    search_criteria jsonb NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    external_service_results jsonb,
    mapped_data jsonb,
    records_upsert_result jsonb,
    submitted_at timestamp with time zone,
    processing_completed_at timestamp with time zone,
    mapping_completed_at timestamp with time zone,
    completed_at timestamp with time zone,
    error_message text,
    error_stage character varying(20),
    kafka_message jsonb,
    kafka_topic character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    batch_id character varying(24),
    integration_setting_ids character varying(24)[] DEFAULT '{}'::character varying[],
    "user" jsonb,
    CONSTRAINT background_checks_error_stage_check CHECK (((error_stage)::text = ANY ((ARRAY['external_services'::character varying, 'mapping'::character varying, 'upsert'::character varying])::text[]))),
    CONSTRAINT background_checks_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'submitted'::character varying, 'processing'::character varying, 'mapping'::character varying, 'completed'::character varying, 'failed'::character varying])::text[]))),
    CONSTRAINT chk_search_criteria_not_empty CHECK ((search_criteria IS NOT NULL))
);


--
-- Name: TABLE background_checks; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.background_checks IS 'Background check requests with single-entry workflow tracking';


--
-- Name: COLUMN background_checks.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.id IS 'Primary key - 24 character string ID';


--
-- Name: COLUMN background_checks.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.user_id IS 'User ID from search criteria';


--
-- Name: COLUMN background_checks.pinpp; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.pinpp IS 'Personal identification number from search criteria';


--
-- Name: COLUMN background_checks.tin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.tin IS 'Tax identification number from search criteria';


--
-- Name: COLUMN background_checks.search_criteria; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.search_criteria IS 'Full search criteria object';


--
-- Name: COLUMN background_checks.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.status IS 'Current workflow status: pending, submitted, processing, mapping, completed, failed';


--
-- Name: COLUMN background_checks.external_service_results; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.external_service_results IS 'Array of results from external background check services';


--
-- Name: COLUMN background_checks.mapped_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.mapped_data IS 'Mapped data ready for records upsert';


--
-- Name: COLUMN background_checks.records_upsert_result; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.records_upsert_result IS 'Final result from records upsert operation';


--
-- Name: COLUMN background_checks.submitted_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.submitted_at IS 'When request was sent to external services';


--
-- Name: COLUMN background_checks.processing_completed_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.processing_completed_at IS 'When all external services responded';


--
-- Name: COLUMN background_checks.mapping_completed_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.mapping_completed_at IS 'When data mapping completed';


--
-- Name: COLUMN background_checks.completed_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.completed_at IS 'When records upsert completed';


--
-- Name: COLUMN background_checks.error_message; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.error_message IS 'Error message if status is failed';


--
-- Name: COLUMN background_checks.error_stage; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.error_stage IS 'Which workflow stage failed';


--
-- Name: COLUMN background_checks.kafka_message; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.kafka_message IS 'Kafka message metadata';


--
-- Name: COLUMN background_checks.kafka_topic; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.kafka_topic IS 'Kafka topic name';


--
-- Name: COLUMN background_checks.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.created_at IS 'Request creation timestamp';


--
-- Name: COLUMN background_checks.created_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.created_by IS 'User who created the request';


--
-- Name: COLUMN background_checks.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.updated_at IS 'Last update timestamp (auto-updated)';


--
-- Name: COLUMN background_checks.batch_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.batch_id IS 'References background_check_batches table to track which batch this request belongs to';


--
-- Name: COLUMN background_checks.integration_setting_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks.integration_setting_ids IS 'Array of integration setting IDs triggered for this request';


--
-- Name: COLUMN background_checks."user"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.background_checks."user" IS 'Snapshot of user information at the time of background check request';


--
-- Name: building_blocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.building_blocks (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    number character varying(255) NOT NULL,
    address character varying(255) NOT NULL,
    name_uz character varying(255) NOT NULL,
    name_ru character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24),
    deleted_at timestamp with time zone
);


--
-- Name: category_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category_mappings (
    id integer NOT NULL,
    category_id integer NOT NULL,
    parent_category_id integer,
    name jsonb NOT NULL,
    internal_doc_type_id character varying(24) NOT NULL,
    doc_type_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: category_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.category_mappings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: category_mappings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.category_mappings_id_seq OWNED BY public.category_mappings.id;


--
-- Name: content_template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.content_template (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    created_by character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_by character varying(255),
    deleted_at timestamp with time zone,
    content jsonb,
    type smallint DEFAULT '1'::smallint
);


--
-- Name: corrector; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.corrector (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    staff_id character varying(24) NOT NULL,
    director_staff_id character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.country (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    code character varying(3) NOT NULL,
    name_en character varying(255) NOT NULL,
    name jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name_ru character varying(255) NOT NULL,
    name_uz character varying(255) NOT NULL,
    name_uz_cryl character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: delivery_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_type (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24),
    db_id character varying(24),
    name jsonb NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: delivery_type_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delivery_type_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: department_structure; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.department_structure (
    id character varying(255) DEFAULT public.generate_object_id() NOT NULL,
    name jsonb NOT NULL,
    type smallint DEFAULT '1'::smallint NOT NULL,
    parent_id character varying(255),
    parent_hierarchy public.ltree,
    short_name jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_id character varying(255),
    created_by character varying(24),
    is_deleted boolean DEFAULT false,
    department_id character varying(24),
    position_id character varying(24)
);


--
-- Name: departments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departments (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24),
    db_id character varying(24) NOT NULL,
    name_uz character varying NOT NULL,
    name_ru character varying NOT NULL,
    name_qqr character varying NOT NULL,
    name_uz_cryl character varying NOT NULL,
    chief_user_id character varying(24),
    parent_id character varying(24),
    parent_hierarchy public.ltree,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    sequence_index text,
    order_index integer DEFAULT 0 NOT NULL,
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint
);


--
-- Name: doc_outgoing_resend; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.doc_outgoing_resend (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    sender_db_id character varying(24) NOT NULL,
    sender_user_id character varying(24) NOT NULL,
    recipient_db_id character varying(24),
    recipient_user_id character varying(24),
    document_id character varying(24),
    document_outgoing_id character varying(24) NOT NULL,
    type smallint NOT NULL,
    active smallint DEFAULT 1,
    contents character varying,
    files jsonb,
    document_year smallint,
    updated_time numeric DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint
);


--
-- Name: COLUMN doc_outgoing_resend.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.doc_outgoing_resend.type IS 'SEND = 1,
	ACCEPT = 2,
	REJECT = 3,
	RESEND = 4,';


--
-- Name: COLUMN doc_outgoing_resend.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.doc_outgoing_resend.active IS '1 - active
0 - inactive';


--
-- Name: document_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_actions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying NOT NULL,
    action character varying NOT NULL,
    action_by character varying NOT NULL,
    action_at timestamp with time zone DEFAULT now() NOT NULL,
    data jsonb
);


--
-- Name: document_aggreement_with_organization_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_aggreement_with_organization_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_aggreement_with_organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_aggreement_with_organizations (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    document_id character varying(24),
    recipient_db_id character varying(255),
    recipient_doc_signer_id character varying(255),
    employee_doc_signer_id character varying(255),
    date_for_visa date,
    date_set_visa date,
    signed_file jsonb,
    status smallint DEFAULT '1'::smallint,
    doc_send_id character varying,
    recipient_department_id character varying,
    document_year integer
);


--
-- Name: document_agreement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_agreement (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    recipient_user_id character varying(24) NOT NULL,
    agreement_type character varying(32) NOT NULL,
    brief_content character varying(255),
    is_deleted boolean DEFAULT false NOT NULL,
    files jsonb,
    agreement_at timestamp with time zone,
    type smallint DEFAULT '1'::smallint NOT NULL,
    "order" smallint NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    document_year smallint NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    active smallint DEFAULT 1 NOT NULL,
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint
);


--
-- Name: document_agreement_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_agreement_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_business_trip; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_business_trip (
    id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24) NOT NULL,
    db_id character varying(24),
    department_id character varying(24),
    address character varying(255),
    from_date date NOT NULL,
    to_date date NOT NULL,
    document_id character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false,
    base character varying(255),
    extended_date date,
    arrival_date date,
    status smallint DEFAULT '0'::smallint,
    signer_user_ids character varying(24)[] DEFAULT '{}'::character varying[],
    document_year integer,
    employee_id character varying(24)
);


--
-- Name: document_business_trip_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_business_trip_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_files_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_files_version (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    document_id character varying(24) NOT NULL,
    file_id character varying(24) NOT NULL,
    action smallint NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: document_flow; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_flow (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24),
    db_id character varying(24),
    parent_id character varying(24),
    document_id character varying(24) NOT NULL,
    document_parent_hierarchy character varying(255),
    task_id character varying(24),
    task_parent_hierarchy character varying(255),
    type smallint NOT NULL,
    recipient_id character varying(24),
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_by character varying(24),
    deleted_at timestamp with time zone,
    recipient_db_id character varying(24),
    contents character varying(255),
    document_year smallint,
    document_parent_hierarchy_arr character varying[] GENERATED ALWAYS AS (
CASE
    WHEN (document_parent_hierarchy IS NOT NULL) THEN string_to_array((document_parent_hierarchy)::text, '.'::text)
    ELSE NULL::text[]
END) STORED,
    recipient_user_id character varying(24),
    controller_id character varying(24),
    document_send_id character varying(24)
);


--
-- Name: document_numbers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_numbers (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    department_id character varying(24) NOT NULL,
    template character varying(32) NOT NULL,
    last_number bigint NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    year bigint NOT NULL,
    category character varying(20) NOT NULL
);


--
-- Name: document_outgoing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_outgoing (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    sender_db_id character varying(24),
    sender_department_id character varying(24),
    sender_user_id character varying(24),
    recipient_db_id character varying(24),
    status smallint DEFAULT '0'::smallint NOT NULL,
    document_id character varying(24) NOT NULL,
    active smallint DEFAULT '1'::smallint NOT NULL,
    document_year smallint NOT NULL,
    response_document_id character varying(24),
    response_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    db_id character varying NOT NULL,
    delivery_type_id character varying(250),
    copy_code integer,
    copy_file character varying(255),
    registered_by character varying(255),
    type smallint,
    document_received_by character varying,
    received_time timestamp with time zone,
    due_date timestamp with time zone,
    updated_time numeric DEFAULT (EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric)
);


--
-- Name: document_outgoing_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_outgoing_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_permissions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying(24) NOT NULL,
    user_id character varying(24) NOT NULL,
    created_by character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: document_qr_code; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_qr_code (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying(24) NOT NULL,
    file_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    archive boolean DEFAULT false NOT NULL,
    document_year smallint NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: document_read_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_read_logs (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    read_at timestamp with time zone DEFAULT now(),
    read_by character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL
);


--
-- Name: document_receiver_groups_for_send_sign; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_receiver_groups_for_send_sign (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    name text NOT NULL,
    chief_ids text[] DEFAULT '{}'::text[]
);


--
-- Name: document_receiver_groups_for_send_sign_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_receiver_groups_for_send_sign_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_send; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_send (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    recipient_user_id character varying(24),
    status smallint DEFAULT 0 NOT NULL,
    is_done boolean DEFAULT false,
    is_deleted boolean DEFAULT false NOT NULL,
    action_at timestamp with time zone,
    action_by character varying(24),
    db_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    has_draft boolean DEFAULT false NOT NULL,
    template_file json,
    fishka_file json,
    reject_info jsonb,
    created_year smallint NOT NULL,
    created_date date DEFAULT CURRENT_DATE NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    secret_type character varying(50) DEFAULT 'SIMPLE'::character varying NOT NULL,
    document_year smallint NOT NULL,
    read_at timestamp with time zone,
    content text,
    doc_main_file json NOT NULL,
    doc_attachment_files jsonb,
    deleted_by character varying,
    deleted_at timestamp with time zone,
    is_main boolean DEFAULT false,
    parent_task_id character varying(24) DEFAULT NULL::character varying,
    recipient_department_id character varying(255),
    doc_signer_id character varying(24),
    template_file_id character varying(24),
    doc_signer_org_id character varying(24),
    cancel_info character varying(255),
    reviewed_at timestamp with time zone,
    sign_type character varying(255),
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint,
    reject_file jsonb,
    menu_type character varying,
    is_controlled boolean DEFAULT false,
    type character varying(10),
    type_v character varying GENERATED ALWAYS AS (
CASE
    WHEN (recipient_user_id IS NULL) THEN 'EXTERNAL'::text
    ELSE 'INTERNAL'::text
END) STORED,
    due_date date
);


--
-- Name: COLUMN document_send.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.document_send.status IS '0 - new, 5 - sent_to_chief, 10 - read, 20 - rejected, 30 - signed';


--
-- Name: document_send_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_send_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_send_signature; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_send_signature (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    document_send_id character varying(24) NOT NULL,
    hash text,
    is_deleted boolean DEFAULT false NOT NULL,
    output_file_id character varying(24) NOT NULL,
    details jsonb NOT NULL,
    pkcs7 text,
    status smallint DEFAULT '1'::smallint NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    document_year smallint,
    created_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    document_id character varying(24),
    is_active boolean DEFAULT true,
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint
);


--
-- Name: document_send_signature_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_send_signature_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_send_staged; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_send_staged (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    recipient_user_id character varying(24),
    status smallint DEFAULT 0 NOT NULL,
    is_done boolean DEFAULT false,
    is_deleted boolean DEFAULT false NOT NULL,
    action_at timestamp with time zone,
    action_by character varying(24),
    db_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    has_draft boolean DEFAULT false NOT NULL,
    template_file json,
    fishka_file json,
    reject_info jsonb,
    created_year smallint NOT NULL,
    created_date date DEFAULT CURRENT_DATE NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    secret_type character varying(50) DEFAULT 'SIMPLE'::character varying NOT NULL,
    document_year smallint NOT NULL,
    read_at timestamp with time zone,
    content text,
    doc_main_file json NOT NULL,
    doc_attachment_files jsonb,
    deleted_by character varying,
    deleted_at timestamp with time zone,
    is_main boolean DEFAULT false,
    parent_task_id character varying(24) DEFAULT NULL::character varying,
    recipient_department_id character varying(255),
    doc_signer_id character varying(24),
    template_file_id character varying(24),
    doc_signer_org_id character varying(24),
    cancel_info character varying(255),
    reviewed_at timestamp with time zone,
    sign_type character varying(255),
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint,
    reject_file jsonb,
    menu_type character varying,
    type character varying(10)
);


--
-- Name: document_signers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_signers (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    org_id character varying(24),
    phone_number character varying(255),
    user_id character varying(24),
    "position" text,
    is_deleted boolean DEFAULT false,
    deleted_by character varying(24),
    full_name text,
    type integer
);


--
-- Name: document_signers_staged; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_signers_staged (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    org_id character varying(24),
    phone_number character varying(255),
    user_id character varying(24),
    "position" text,
    is_deleted boolean DEFAULT false,
    deleted_by character varying(24),
    full_name text,
    type integer
);


--
-- Name: document_subject; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_subject (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    name jsonb NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    parent_id character varying(24),
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    document_type_id character varying(24),
    department_ids character varying(24)[]
);


--
-- Name: document_subject_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_subject_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: document_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.document_types (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    name_uz character varying(32) NOT NULL,
    name_ru character varying(32) NOT NULL,
    name_qqr character varying(32) NOT NULL,
    name_uz_latin character varying(32) NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    type_id character varying(24) NOT NULL,
    brief_content_krill text,
    document_name character varying(255) NOT NULL,
    document_number character varying(32) NOT NULL,
    document_date date NOT NULL,
    main_file jsonb NOT NULL,
    parent_document_id character varying(24),
    journal_id character varying(24),
    parent_hierarchy public.ltree,
    due_date date,
    status smallint DEFAULT 1 NOT NULL,
    is_done boolean DEFAULT false,
    registration_number character varying(100),
    deleted_by character varying(24),
    deleted_at timestamp with time zone,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    attachments jsonb[],
    is_active boolean DEFAULT true NOT NULL,
    year bigint NOT NULL,
    label_ids character varying(255),
    secret_type public.document_secret_type DEFAULT 'SIMPLE'::public.document_secret_type NOT NULL,
    internal_doc_type_id character varying(24),
    updated_at timestamp with time zone,
    lang character varying(25),
    comment character varying,
    list_count smallint,
    attachment_count smallint,
    attachment_list_count smallint,
    is_controlled boolean DEFAULT false,
    additional_signers character varying[],
    main_signer_id character varying(24),
    main_signer_db_id character varying(24),
    brief_content_uz_latn text,
    brief_content_ru text,
    subject_id character varying(24),
    auto_reg_generate boolean DEFAULT false,
    is_published boolean DEFAULT false,
    custom_input text,
    created_by_department_id character varying(24),
    subject_ids character varying[],
    subject_child_ids character varying[],
    resolution_template_file_id character varying(24),
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint,
    data jsonb,
    task_point integer DEFAULT 0,
    regulation_count integer DEFAULT 0,
    category smallint,
    receiver_users character varying[],
    nomenclature_ids character varying[],
    nomenclature_json jsonb
);


--
-- Name: COLUMN documents.task_point; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.documents.task_point IS 'Task point value for KPI calculation';


--
-- Name: COLUMN documents.regulation_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.documents.regulation_count IS 'Count of regulation attachments (special attachments with legal/normative value)';


--
-- Name: COLUMN documents.category; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.documents.category IS 'Document category: 1=new, 2=update, 3=other';


--
-- Name: COLUMN documents.receiver_users; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.documents.receiver_users IS 'Array of user IDs who are receivers of the document';


--
-- Name: COLUMN documents.nomenclature_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.documents.nomenclature_ids IS 'Array of nomenclature IDs associated with the document (optional)';


--
-- Name: COLUMN documents.nomenclature_json; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.documents.nomenclature_json IS 'Full nomenclature information as JSONB array (populated from nomenclature_ids)';


--
-- Name: documents_count; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents_count (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    created_by character varying(24) NOT NULL,
    type_id character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    year smallint NOT NULL,
    total_count bigint NOT NULL,
    internal_doc_type_id character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: docx_file_annotations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.docx_file_annotations (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    file_id character varying(24) NOT NULL,
    annotation text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(24)
);


--
-- Name: download_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.download_logs (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    user_id character varying(24),
    download_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    file_id character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: drawing_journal_number_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drawing_journal_number_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    type character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    new_value text NOT NULL,
    old_value text NOT NULL,
    main_id character varying(255),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: drawing_journal_number_gen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drawing_journal_number_gen (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    classification smallint,
    drawing jsonb NOT NULL,
    department_id character varying(255),
    sign_user_id character varying(255),
    work_user_id character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    doc_type_id character varying(255),
    journal_id character varying(24) NOT NULL,
    journal_json jsonb NOT NULL
);


--
-- Name: duty_schedule_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.duty_schedule_group (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_id character varying(24),
    group_name character varying(255) NOT NULL,
    date date,
    "from" time without time zone,
    "to" time without time zone,
    parent_id character varying(24),
    parent_hierarchy public.ltree,
    is_deleted boolean DEFAULT false
);


--
-- Name: duty_schedule_groups_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.duty_schedule_groups_users (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    group_id character varying(24),
    full_name character varying(255) NOT NULL,
    phone character varying(255) NOT NULL,
    is_main boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: egov_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.egov_tokens (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    service_name character varying(100) NOT NULL,
    access_token text NOT NULL,
    access_token_expires_at timestamp without time zone NOT NULL,
    expires_in integer NOT NULL,
    token_type character varying(50) DEFAULT 'Bearer'::character varying,
    metadata jsonb,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE egov_tokens; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.egov_tokens IS 'Stores eGov API access tokens with automatic expiration tracking';


--
-- Name: COLUMN egov_tokens.service_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.egov_tokens.service_name IS 'Service identifier (e.g., egov_main)';


--
-- Name: COLUMN egov_tokens.expires_in; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.egov_tokens.expires_in IS 'Token TTL in seconds';


--
-- Name: COLUMN egov_tokens.metadata; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.egov_tokens.metadata IS 'Additional token metadata (consumer_key, username, etc.)';


--
-- Name: event_handlers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_handlers (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name character varying(255),
    description text,
    tags text[] DEFAULT '{}'::text[],
    triggers jsonb DEFAULT '[]'::jsonb,
    actions jsonb DEFAULT '[]'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_actions_is_array CHECK ((jsonb_typeof(actions) = 'array'::text)),
    CONSTRAINT chk_actions_min_items CHECK ((jsonb_array_length(actions) >= 1)),
    CONSTRAINT chk_description_min_length CHECK (((description IS NULL) OR (length(TRIM(BOTH FROM description)) >= 1))),
    CONSTRAINT chk_name_min_length CHECK (((name IS NULL) OR (length(TRIM(BOTH FROM name)) >= 1))),
    CONSTRAINT chk_tags_is_array CHECK ((tags IS NOT NULL)),
    CONSTRAINT chk_tags_min_items CHECK (((tags IS NULL) OR (array_length(tags, 1) >= 1))),
    CONSTRAINT chk_triggers_is_array CHECK (((triggers IS NULL) OR (jsonb_typeof(triggers) = 'array'::text)))
);


--
-- Name: event_pool; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_pool (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    event_id character varying(255),
    topic character varying(255) NOT NULL,
    event_type character varying(255) NOT NULL,
    source_system character varying(255) NOT NULL,
    raw_message jsonb NOT NULL,
    data jsonb NOT NULL,
    process_data jsonb,
    processing_at timestamp with time zone,
    processed_at timestamp with time zone,
    processing_status character varying(50) DEFAULT 'PENDING'::character varying NOT NULL,
    event_handler_id character varying(24),
    retries integer DEFAULT 0 NOT NULL,
    log jsonb,
    organization_id character varying(24),
    "timestamp" timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_data_is_object CHECK (((data IS NOT NULL) AND (jsonb_typeof(data) = 'object'::text))),
    CONSTRAINT chk_event_type_min_length CHECK ((length(TRIM(BOTH FROM event_type)) >= 1)),
    CONSTRAINT chk_log_is_array CHECK (((log IS NULL) OR (jsonb_typeof(log) = 'array'::text))),
    CONSTRAINT chk_process_data_is_object CHECK (((process_data IS NULL) OR (jsonb_typeof(process_data) = 'object'::text))),
    CONSTRAINT chk_processing_status CHECK (((processing_status)::text = ANY ((ARRAY['PENDING'::character varying, 'PROCESSED'::character varying, 'FAILED'::character varying, 'REPROCESSING'::character varying])::text[]))),
    CONSTRAINT chk_raw_message_is_object CHECK (((raw_message IS NOT NULL) AND (jsonb_typeof(raw_message) = 'object'::text))),
    CONSTRAINT chk_retries_minimum CHECK ((retries >= 0)),
    CONSTRAINT chk_source_system_min_length CHECK ((length(TRIM(BOTH FROM source_system)) >= 1)),
    CONSTRAINT chk_topic_min_length CHECK ((length(TRIM(BOTH FROM topic)) >= 1))
);


--
-- Name: excel_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.excel_templates (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    name character varying NOT NULL,
    template_file_id character varying(24) NOT NULL,
    code character varying NOT NULL
);


--
-- Name: execution_control_tabs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.execution_control_tabs (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    name text NOT NULL,
    document_type_ids text[] DEFAULT '{}'::text[],
    internal_doc_type_ids text[] DEFAULT '{}'::text[],
    user_ids character varying[] DEFAULT '{}'::character varying[]
);


--
-- Name: execution_flow; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.execution_flow (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    type character varying NOT NULL,
    data_id character varying(24) NOT NULL,
    data json NOT NULL,
    main_document_id character varying(24) NOT NULL,
    parent_id character varying(24),
    updated_at timestamp with time zone,
    updated_by character varying(24),
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    deleted_by character varying(24),
    parent_document_id character varying(24),
    parent_hierarchy text,
    path public.ltree,
    depth integer DEFAULT 0
);


--
-- Name: COLUMN execution_flow.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.execution_flow.type IS 'DOCUMENT,
AGREEMENT,
SIGN,
SIGN_WITH_ORG,
RESOLUTION,
OUTGOING,
TASK,
TASK_RECIPIENT';


--
-- Name: COLUMN execution_flow.parent_document_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.execution_flow.parent_document_id IS 'Parent document ID for document hierarchy (parent-child relationships)';


--
-- Name: COLUMN execution_flow.parent_hierarchy; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.execution_flow.parent_hierarchy IS 'Full document hierarchy path (dot-separated IDs)';


--
-- Name: COLUMN execution_flow.path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.execution_flow.path IS 'Materialized path for tree navigation (ltree format)';


--
-- Name: COLUMN execution_flow.depth; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.execution_flow.depth IS 'Depth level in the tree (0 = root)';


--
-- Name: failed_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.failed_logs (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    table_name character varying(64) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    kafka_message json,
    retry_count smallint DEFAULT '0'::smallint NOT NULL,
    error_message text,
    is_migrated boolean DEFAULT false NOT NULL,
    service character varying
);


--
-- Name: favorite_organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorite_organizations (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    user_id character varying(24) NOT NULL,
    department_id character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    favorite_db_id character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: favorite_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorite_tasks (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    recipient_id character varying(24) NOT NULL,
    task_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    document_year smallint NOT NULL,
    db_id character varying(24) NOT NULL
);


--
-- Name: file_host; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.file_host (
    id smallint NOT NULL,
    name character varying(30) NOT NULL,
    description character varying(255),
    is_archived boolean,
    details jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.files (
    id character varying(24) NOT NULL,
    db_id character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24),
    is_deleted boolean DEFAULT false,
    type character varying(255),
    name character varying(255),
    size integer,
    content_size integer,
    is_private boolean DEFAULT false,
    file_host_id smallint DEFAULT '1'::smallint,
    hash character varying(255),
    last_modified timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    info jsonb
)
WITH (fillfactor='96');


--
-- Name: fraction_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fraction_members (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    director_user_id character varying(24),
    is_deleted boolean DEFAULT false NOT NULL,
    type character varying(16),
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    name_uz character varying(256)
);


--
-- Name: generate_journal_number; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.generate_journal_number (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    journal_id character varying(24) NOT NULL,
    seq_number bigint NOT NULL,
    date_row date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    year bigint NOT NULL
);


--
-- Name: generate_journal_number_change; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.generate_journal_number_change (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24),
    created_by_json jsonb,
    journal_id character varying(24),
    generate_journal_number_id character varying(24),
    old_value jsonb,
    new_value jsonb,
    action character varying(50)
);


--
-- Name: generate_journal_number_list; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.generate_journal_number_list (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    journal_number_id character varying(24) NOT NULL,
    document_id character varying(24),
    seq_number bigint NOT NULL,
    generate_draw_way character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24),
    db_id character varying(24),
    journal_id character varying(24),
    draw_way jsonb NOT NULL,
    document_year smallint
);


--
-- Name: guest_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guest_documents (
    id character varying(24) NOT NULL,
    guest_id character varying(24) NOT NULL,
    document_type character varying(255) NOT NULL,
    document_serial_number character varying(255) NOT NULL,
    document_expire_date character varying(255),
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone,
    pinfl character varying(255)
);


--
-- Name: guest_request_approvals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guest_request_approvals (
    id character varying(255) NOT NULL,
    guest_request_id character varying(255) NOT NULL,
    approver_id character varying(255),
    approver_sign text,
    approved_at timestamp with time zone,
    completion_approver_id character varying(255),
    completion_approver_sign text,
    completed_at timestamp with time zone,
    rejected_by character varying(255),
    rejection_reason character varying(255),
    rejected_at timestamp with time zone,
    created_by character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp with time zone
);


--
-- Name: guest_request_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guest_request_logs (
    id character varying(255) NOT NULL,
    guest_request_id character varying(255) NOT NULL,
    action character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(255) NOT NULL
);


--
-- Name: guest_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guest_requests (
    id character varying(255) NOT NULL,
    recipient_user_id character varying(255),
    visit_purpose character varying(255) NOT NULL,
    room_number character varying(255) NOT NULL,
    image_json json,
    guest_id character varying(255),
    first_name character varying(255),
    last_name character varying(255),
    middle_name character varying(255),
    organization character varying(255),
    "position" character varying(255),
    phone_number character varying(255),
    came_at timestamp with time zone,
    left_at timestamp with time zone,
    expire_at timestamp with time zone,
    status character varying(255) DEFAULT 'pending'::character varying,
    last_action character varying(255),
    created_by character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp with time zone,
    block_id character varying(24),
    updated_at timestamp with time zone,
    CONSTRAINT guest_requests_check CHECK (((guest_id IS NOT NULL) OR ((first_name IS NOT NULL) AND (last_name IS NOT NULL) AND (middle_name IS NOT NULL) AND (organization IS NOT NULL) AND ("position" IS NOT NULL))))
);


--
-- Name: guests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guests (
    id character varying(255) NOT NULL,
    created_by character varying(255),
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    middle_name character varying(255) NOT NULL,
    pinfl character varying(255),
    date_of_birth character varying(255),
    phone_number character varying(255) NOT NULL,
    organization character varying(255) NOT NULL,
    "position" character varying(255) NOT NULL,
    last_visit timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone,
    deleted_at timestamp with time zone
);


--
-- Name: incoming_document_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incoming_document_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: incoming_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incoming_documents (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24),
    sender_number character varying(255),
    sender_date date,
    delivery_type_id character varying(24),
    is_deleted boolean DEFAULT false,
    document_id character varying(255) NOT NULL,
    base character varying(255),
    developed_by_db_id character varying(24),
    incoming_document_id character varying(24)
);


--
-- Name: COLUMN incoming_documents.sender_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.incoming_documents.sender_number IS 'Kirish raqami';


--
-- Name: COLUMN incoming_documents.sender_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.incoming_documents.sender_date IS 'Kirish sanasi';


--
-- Name: COLUMN incoming_documents.delivery_type_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.incoming_documents.delivery_type_id IS 'Yetkazib berish turi';


--
-- Name: COLUMN incoming_documents.base; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.incoming_documents.base IS 'Base document reference';


--
-- Name: COLUMN incoming_documents.developed_by_db_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.incoming_documents.developed_by_db_id IS 'Database ID of the organization that developed the document';


--
-- Name: initiative_doc_recipients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.initiative_doc_recipients (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    recipient_user_id character varying(24) NOT NULL,
    is_main boolean NOT NULL,
    recipient_user_json jsonb,
    recipient_department_id character varying(24),
    initiative_doc_id character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: initiative_nhh_docs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.initiative_nhh_docs (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    status public.initiative_doc_status DEFAULT 'new'::public.initiative_doc_status NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    rejection_reason text
);


--
-- Name: inner_document_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inner_document_type (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name_uz character varying(255) NOT NULL,
    name_ru character varying(255) NOT NULL,
    name_uz_lat character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false,
    department_id character varying(24) NOT NULL,
    type character varying(255) NOT NULL,
    sender_organization_id character varying(24) NOT NULL,
    due_day bigint NOT NULL,
    classifications bigint NOT NULL,
    info jsonb NOT NULL
);


--
-- Name: integration_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integration_settings (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    method_name character varying(255) NOT NULL,
    service_name character varying(100) NOT NULL,
    http_method character varying(10) DEFAULT 'POST'::character varying NOT NULL,
    endpoint text NOT NULL,
    base_url text,
    default_body jsonb,
    default_headers jsonb,
    default_query_params jsonb,
    description text,
    category character varying(100),
    timeout integer DEFAULT 60000,
    is_active boolean DEFAULT true NOT NULL,
    requires_auth boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24),
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by character varying(24),
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    deleted_by character varying(24),
    parent_id character varying(24),
    delay_ms integer DEFAULT 0,
    polling_config jsonb,
    response_mapping jsonb,
    is_available boolean DEFAULT true NOT NULL,
    last_checked_at timestamp with time zone,
    unavailable_reason text
);


--
-- Name: COLUMN integration_settings.delay_ms; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.integration_settings.delay_ms IS 'Optional delay in milliseconds before executing the integration';


--
-- Name: COLUMN integration_settings.polling_config; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.integration_settings.polling_config IS 'Configuration for asynchronous polling (interval_ms, max_attempts, success_condition)';


--
-- Name: COLUMN integration_settings.response_mapping; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.integration_settings.response_mapping IS 'Mapping of parent response fields to child request parameters';


--
-- Name: COLUMN integration_settings.is_available; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.integration_settings.is_available IS 'Whether the integration endpoint is considered available';


--
-- Name: COLUMN integration_settings.last_checked_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.integration_settings.last_checked_at IS 'Last time the availability status was verified';


--
-- Name: COLUMN integration_settings.unavailable_reason; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.integration_settings.unavailable_reason IS 'Reason for unavailability (e.g., specific error message or status code)';


--
-- Name: integrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.integrations (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    request_id character varying(24) NOT NULL,
    integration_setting_id character varying(24),
    method_name character varying(255) NOT NULL,
    status character varying(50) NOT NULL,
    raw_data jsonb,
    record_id character varying(24),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    error_message text,
    error_code character varying(100),
    user_id character varying(24),
    pinpp character varying(50),
    search_criteria jsonb,
    record_ids character varying(24)[],
    request_body jsonb
);


--
-- Name: TABLE integrations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.integrations IS 'Stores individual integration results. Each row represents one external service call (e.g., address_info, passport_info). Links to background_checks via request_id.';


--
-- Name: COLUMN integrations.request_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.integrations.request_id IS 'Reference to background_checks table - the parent request';


--
-- Name: COLUMN integrations.raw_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.integrations.raw_data IS 'Raw response data from external service (e.g., eGov)';


--
-- Name: COLUMN integrations.record_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.integrations.record_id IS 'DEPRECATED: Use record_ids array instead. Single record ID created by workflow';


--
-- Name: COLUMN integrations.error_message; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.integrations.error_message IS 'Error message if integration failed';


--
-- Name: COLUMN integrations.error_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.integrations.error_code IS 'Error code for categorizing the error type';


--
-- Name: COLUMN integrations.search_criteria; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.integrations.search_criteria IS 'Original search criteria used for this integration';


--
-- Name: COLUMN integrations.record_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.integrations.record_ids IS 'Array of record IDs created by workflow engine for this integration';


--
-- Name: COLUMN integrations.request_body; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.integrations.request_body IS 'Actual request body sent to external service (after placeholder replacement)';


--
-- Name: internal_doc_type_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internal_doc_type_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: internal_doc_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internal_doc_types (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    name_json jsonb NOT NULL,
    parent_doc_type_id character varying(24) NOT NULL,
    created_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    order_index integer DEFAULT 0 NOT NULL,
    journal_id character varying(24),
    code character varying(100),
    department_ids character varying(24)[],
    permissions character varying(255)[],
    default_config jsonb,
    hidden boolean
);


--
-- Name: COLUMN internal_doc_types.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.internal_doc_types.code IS 'Unique string code/enum identifier for the internal document type';


--
-- Name: COLUMN internal_doc_types.department_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.internal_doc_types.department_ids IS 'Array of department IDs that can access this internal document type. NULL means global (accessible to all departments)';


--
-- Name: COLUMN internal_doc_types.permissions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.internal_doc_types.permissions IS 'Array of role names (e.g., HR_HEAD_ROLE) that can edit/delete this internal doc type. NULL means everyone can edit/delete.';


--
-- Name: internal_document_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internal_document_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: internal_document_flow_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internal_document_flow_events (
    id character varying(24) NOT NULL,
    root_document_id character varying(24) NOT NULL,
    trigger_document_id character varying(24) NOT NULL,
    event_type character varying(50) NOT NULL,
    from_status character varying(100),
    to_status character varying(100) NOT NULL,
    comment text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: internal_document_flow_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internal_document_flow_state (
    root_document_id character varying(24) NOT NULL,
    current_flow_status character varying(100) NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: internal_document_relations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internal_document_relations (
    id character varying(24) NOT NULL,
    parent_id character varying(24) NOT NULL,
    child_id character varying(24) NOT NULL,
    relation_type character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: internal_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internal_documents (
    id character varying(255) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false,
    deleted_at timestamp with time zone,
    deleted_by character varying(255),
    document_id character varying(255) NOT NULL,
    recipient_user_ids character varying(24)[] DEFAULT '{}'::character varying[] NOT NULL,
    signer_user_ids character varying(24)[] DEFAULT '{}'::character varying[] NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    sender_department_id character varying(255),
    sender_user_id character varying(255),
    registered_by character varying(255),
    task_recipient_id character varying,
    task_id character varying,
    main_signer_id character varying(24),
    status character varying(50) DEFAULT 'DRAFT'::character varying,
    viewed_at timestamp with time zone,
    viewed_by character varying(24)
);


--
-- Name: COLUMN internal_documents.viewed_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.internal_documents.viewed_at IS 'Timestamp when the internal document was viewed by a user with HR_MODULE permission';


--
-- Name: COLUMN internal_documents.viewed_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.internal_documents.viewed_by IS 'User ID who viewed the internal document (only set for users with HR_MODULE permission)';


--
-- Name: internal_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internal_notifications (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    event_id character varying(36) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    service_name character varying(255) NOT NULL,
    category character varying(255) NOT NULL,
    severity character varying(10) NOT NULL,
    title character varying(500) NOT NULL,
    message text NOT NULL,
    details jsonb,
    request_id character varying(255),
    trace_id character varying(255),
    tags text[],
    stack_trace text,
    error_code character varying(100),
    http_status_code integer,
    user_agent character varying(500),
    endpoint character varying(500),
    ip_address character varying(50),
    request_method character varying(10),
    request_body jsonb,
    response_body jsonb,
    db_status character varying(20) DEFAULT 'SENT'::character varying NOT NULL,
    db_attempt_count integer DEFAULT 0 NOT NULL,
    db_next_attempt_at timestamp with time zone,
    db_last_error text,
    telegram_status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    telegram_attempt_count integer DEFAULT 0 NOT NULL,
    telegram_next_attempt_at timestamp with time zone,
    telegram_last_error text,
    CONSTRAINT internal_notifications_db_status_check CHECK (((db_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SENT'::character varying, 'FAILED'::character varying, 'SKIPPED'::character varying])::text[]))),
    CONSTRAINT internal_notifications_severity_check CHECK (((severity)::text = ANY ((ARRAY['ERROR'::character varying, 'WARNING'::character varying, 'INFO'::character varying])::text[]))),
    CONSTRAINT internal_notifications_telegram_status_check CHECK (((telegram_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SENT'::character varying, 'FAILED'::character varying, 'SKIPPED'::character varying])::text[])))
);


--
-- Name: journal; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journal (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    name jsonb NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    prefix character varying(100),
    updated_at timestamp with time zone,
    created_date date DEFAULT CURRENT_TIMESTAMP,
    doc_type_id character varying(255),
    auto_reg_generate boolean DEFAULT true,
    secret_type public.document_secret_type,
    department_ids character varying[],
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint,
    code character varying(255),
    permissions character varying(255)[],
    hidden boolean
);


--
-- Name: COLUMN journal.permissions; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.journal.permissions IS 'Array of role names (e.g., HR_HEAD_ROLE) that can edit/delete this journal. NULL means everyone can edit/delete.';


--
-- Name: journal_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.journal_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: kafka_processes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kafka_processes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    topic text,
    data jsonb,
    status character varying(255),
    error text,
    done_retries smallint DEFAULT 1,
    max_retries smallint DEFAULT 5
);


--
-- Name: kpi_failed_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kpi_failed_transactions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24),
    db_id character varying(36),
    kpi_data jsonb NOT NULL,
    user_id character varying(24) NOT NULL,
    status smallint DEFAULT '1'::smallint,
    error character varying(255)
);


--
-- Name: kpi_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.kpi_transactions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    task_id character varying(24) NOT NULL,
    recipient_id character varying(24) NOT NULL,
    send_action_id character varying(24) NOT NULL,
    point character varying(255) NOT NULL,
    department_id character varying(24) NOT NULL,
    user_id character varying(24) NOT NULL,
    type smallint NOT NULL,
    log jsonb NOT NULL,
    bonus_point character varying(255) DEFAULT '0'::character varying NOT NULL,
    request_id character varying(24) NOT NULL,
    document_year smallint NOT NULL
);


--
-- Name: labels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.labels (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name character varying(255) NOT NULL,
    text_color character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    updated_by character varying(24),
    updated_at timestamp with time zone,
    db_id character varying(24),
    deleted_at timestamp with time zone,
    deleted_by character varying(24),
    bg_color character varying(255),
    type integer DEFAULT 1
);


--
-- Name: library_book_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.library_book_files (
    id integer NOT NULL,
    library_book_id integer,
    name character varying,
    sysfile bytea,
    seq integer,
    remark character varying,
    autodoc_fn character varying,
    sys_date date
);


--
-- Name: library_books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.library_books (
    id_library_books integer NOT NULL,
    id_library_cats integer,
    name character varying,
    author character varying,
    code character varying,
    publisher character varying,
    book bytea,
    book_filename character varying,
    autodoc_fn character varying,
    publish_date date,
    seq integer,
    content_html bytea,
    content text,
    summary text,
    department character varying,
    performer character varying,
    mission character varying,
    doc_id integer,
    doc_type integer
);


--
-- Name: library_cats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.library_cats (
    id_library_cats integer,
    name_rus character varying(500),
    name_uzb character varying(500),
    name_lat character varying(500),
    id_library_cats_parent integer,
    seq integer,
    description character varying(4000),
    type integer
);


--
-- Name: linked_document; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.linked_document (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying(24) NOT NULL,
    linked_document_id character varying(24) NOT NULL,
    document_year smallint NOT NULL
);


--
-- Name: members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    user_id character varying(24) NOT NULL
);


--
-- Name: migration_progress; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migration_progress (
    id integer NOT NULL,
    migration_type character varying(20) NOT NULL,
    oracle_id integer NOT NULL,
    pg_id character varying(24),
    status character varying(20) NOT NULL,
    error_message text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: migration_progress_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.migration_progress_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: migration_progress_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.migration_progress_id_seq OWNED BY public.migration_progress.id;


--
-- Name: news; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.news (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    title character varying NOT NULL,
    brief_content text NOT NULL,
    content text NOT NULL,
    attachments jsonb,
    is_deleted boolean DEFAULT false NOT NULL,
    type character varying DEFAULT 'GENERAL'::character varying NOT NULL,
    active_from timestamp with time zone,
    active_to timestamp with time zone
);


--
-- Name: news_read_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.news_read_logs (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    news_id character varying(24) NOT NULL,
    user_id character varying(24) NOT NULL,
    read_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: newspapers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.newspapers (
    id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24) NOT NULL,
    name character varying(255),
    db_id character varying(24),
    file_id character varying(255) NOT NULL,
    files jsonb NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: nhh_agreement_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_agreement_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    main_id character varying(24) NOT NULL,
    action character varying(255) NOT NULL,
    key_name character varying(255),
    old_value text,
    new_value text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: nhh_agreements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_agreements (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    type public.nhh_agreement_type NOT NULL,
    recipient_db_id character varying(24),
    recipient_db_json jsonb,
    recipient_department_id character varying(24),
    recipient_department_json jsonb,
    status public.nhh_agreement_status DEFAULT 'disagree'::public.nhh_agreement_status NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    deleted_by character varying(24)
);


--
-- Name: nhh_kpi; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_kpi (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying(255) NOT NULL,
    task_id character varying(255) NOT NULL,
    depth integer NOT NULL,
    kpi_type character varying(50) NOT NULL,
    score numeric(10,2) NOT NULL,
    type character varying(20) NOT NULL,
    is_active boolean DEFAULT true,
    user_id character varying(255) NOT NULL,
    recipient_id character varying(255) NOT NULL,
    document_date date,
    internal_doc_type_id character varying(255),
    document_year integer,
    created_at timestamp without time zone DEFAULT now(),
    due_date_type character varying(20),
    updated_at timestamp without time zone DEFAULT now(),
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT nhh_kpi_data_not_empty CHECK (((data <> '{}'::jsonb) AND (data IS NOT NULL)))
);


--
-- Name: TABLE nhh_kpi; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.nhh_kpi IS 'NHH KPI calculation data with history tracking';


--
-- Name: COLUMN nhh_kpi.document_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi.document_id IS 'Root incoming document (type_id = INCOMING_DOC_TYPE)';


--
-- Name: COLUMN nhh_kpi.task_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi.task_id IS 'Related task (main or child document task)';


--
-- Name: COLUMN nhh_kpi.depth; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi.depth IS 'Depth from parent_hierarchy';


--
-- Name: COLUMN nhh_kpi.kpi_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi.kpi_type IS 'main_point, task_point, attachment_point, pages_point, category_point, recipient_type_point, project_type_point, due_date_point';


--
-- Name: COLUMN nhh_kpi.score; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi.score IS 'The calculated score value';


--
-- Name: COLUMN nhh_kpi.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi.type IS '''point'' (added) or ''coefficient'' (multiplied)';


--
-- Name: COLUMN nhh_kpi.is_active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi.is_active IS 'Soft delete flag - only deepest task recipient''s KPI records remain active';


--
-- Name: COLUMN nhh_kpi.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi.user_id IS 'User being evaluated';


--
-- Name: COLUMN nhh_kpi.recipient_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi.recipient_id IS 'task_recipient being scored';


--
-- Name: COLUMN nhh_kpi.document_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi.document_date IS 'Document date for filtering';


--
-- Name: COLUMN nhh_kpi.internal_doc_type_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi.internal_doc_type_id IS 'Internal doc type for filtering (PROJECT_INTERNAL_DOC_TYPES)';


--
-- Name: COLUMN nhh_kpi.document_year; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi.document_year IS 'Extracted year for fast filtering';


--
-- Name: COLUMN nhh_kpi.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi.created_at IS 'KPI record creation date';


--
-- Name: COLUMN nhh_kpi.due_date_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi.due_date_type IS 'on_time, before_time, after_time';


--
-- Name: COLUMN nhh_kpi.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi.updated_at IS 'Last update timestamp';


--
-- Name: COLUMN nhh_kpi.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi.data IS 'Detailed KPI calculation data including inputs, config, formula, and result (JSONB)';


--
-- Name: nhh_kpi_coeff_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_kpi_coeff_version (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    activation_date date NOT NULL,
    active smallint DEFAULT 1 NOT NULL,
    created_by character varying(24) NOT NULL
);


--
-- Name: COLUMN nhh_kpi_coeff_version.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_kpi_coeff_version.active IS '0 - inactive
1 - active';


--
-- Name: nhh_kpi_document_setting_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_kpi_document_setting_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    main_id character varying(24) NOT NULL,
    action character varying(255) NOT NULL,
    key_name character varying(255),
    old_value text,
    new_value text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: nhh_kpi_document_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_kpi_document_settings (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying(255) NOT NULL,
    task_id character varying(255),
    kpi_type_id character varying(24) NOT NULL,
    value character varying(255),
    data jsonb,
    is_finalized boolean DEFAULT false NOT NULL,
    finalized_at timestamp with time zone,
    finalized_by character varying(24),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    deleted_by character varying(24)
);


--
-- Name: nhh_kpi_due_date_ranges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_kpi_due_date_ranges (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    version_id character varying(24) NOT NULL,
    kpi_type_id character varying(24) NOT NULL,
    min_days integer,
    max_days integer,
    is_before_due boolean DEFAULT false NOT NULL,
    is_on_due boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    deleted_by character varying(24)
);


--
-- Name: nhh_kpi_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_kpi_records (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    version_id character varying(24) NOT NULL,
    kpi_type_id character varying(24) NOT NULL,
    document_id character varying(255) NOT NULL,
    task_id character varying(255),
    depth integer NOT NULL,
    score numeric(10,2) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    recipient_user_id character varying(255) NOT NULL,
    recipient_id character varying(255),
    document_date date,
    internal_doc_type_id character varying(255),
    document_year integer,
    due_date_type character varying(20),
    data jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    updated_at timestamp with time zone,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    deleted_by character varying(24)
);


--
-- Name: nhh_kpi_type_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_kpi_type_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    main_id character varying(24) NOT NULL,
    action character varying(255) NOT NULL,
    key_name character varying(255),
    old_value text,
    new_value text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: nhh_kpi_type_config_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_kpi_type_config_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    main_id character varying(24) NOT NULL,
    action character varying(255) NOT NULL,
    key_name character varying(255),
    old_value text,
    new_value text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: nhh_kpi_type_configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_kpi_type_configs (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    version_id character varying(24) NOT NULL,
    kpi_type_id character varying(24) NOT NULL,
    internal_doc_type_id character varying(255) NOT NULL,
    value numeric(10,4),
    formula character varying(500),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    deleted_by character varying(24)
);


--
-- Name: nhh_kpi_type_group_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_kpi_type_group_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    main_id character varying(24) NOT NULL,
    action character varying(255) NOT NULL,
    key_name character varying(255),
    old_value text,
    new_value text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: nhh_kpi_type_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_kpi_type_groups (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name jsonb NOT NULL,
    key character varying(100) NOT NULL,
    selection_type public.nhh_kpi_selection_type NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    deleted_by character varying(24)
);


--
-- Name: nhh_kpi_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_kpi_types (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name jsonb NOT NULL,
    key character varying(100) NOT NULL,
    score_type public.nhh_kpi_score_type NOT NULL,
    group_id character varying(24),
    is_required boolean DEFAULT false NOT NULL,
    is_system boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    deleted_by character varying(24)
);


--
-- Name: nhh_kpi_version_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_kpi_version_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    main_id character varying(24) NOT NULL,
    action character varying(255) NOT NULL,
    key_name character varying(255),
    old_value text,
    new_value text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: nhh_kpi_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_kpi_versions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name character varying(255) NOT NULL,
    activation_date date NOT NULL,
    status public.nhh_kpi_version_status DEFAULT 'upcoming'::public.nhh_kpi_version_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL
);


--
-- Name: nhh_toifa; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nhh_toifa (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name_uz character varying,
    name_uz_latn character varying,
    name_ru integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    active smallint,
    nhh_type smallint NOT NULL
);


--
-- Name: COLUMN nhh_toifa.active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_toifa.active IS '0 - inactive
1 - active ';


--
-- Name: COLUMN nhh_toifa.nhh_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nhh_toifa.nhh_type IS '1 - ball
2 - ilova
3 - toifa
4 - muddat';


--
-- Name: nomenclatures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nomenclatures (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    deleted_by character varying(24),
    code character varying(255) NOT NULL,
    name jsonb NOT NULL,
    year integer NOT NULL,
    parent_id character varying(24) DEFAULT NULL::character varying
);


--
-- Name: TABLE nomenclatures; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.nomenclatures IS 'Nomenclature records with code, name (JSONB), and year';


--
-- Name: COLUMN nomenclatures.code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nomenclatures.code IS 'Nomenclature code';


--
-- Name: COLUMN nomenclatures.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nomenclatures.name IS 'Nomenclature name stored as JSONB (supports multiple languages)';


--
-- Name: COLUMN nomenclatures.year; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nomenclatures.year IS 'Year associated with the nomenclature';


--
-- Name: COLUMN nomenclatures.parent_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.nomenclatures.parent_id IS 'Parent nomenclature ID (null for root/parent items)';


--
-- Name: normative_doc_bases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.normative_doc_bases (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    content character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false
);


--
-- Name: normative_document_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.normative_document_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: normative_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.normative_documents (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24),
    db_id character varying(36),
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    deleted_by character varying(24),
    document_id character varying(24) NOT NULL,
    validity_loss text,
    changes_made character varying(255),
    sender_department_id character varying(255),
    sender_user_id character varying(255),
    base character varying,
    project_ids character varying(24)[]
);


--
-- Name: normative_legal_docs_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.normative_legal_docs_tasks (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24),
    db_id character varying(24),
    recipient_user_id character varying(24) NOT NULL,
    recipient_db_id character varying(24),
    name character varying(255),
    type smallint,
    due_date date,
    status smallint,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_by character varying(24),
    deleted_at timestamp with time zone,
    last_updated_by character varying(24),
    last_updated_at timestamp with time zone
);


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notifications (
    id character varying(255) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying(255) NOT NULL,
    task_id character varying(255),
    message text NOT NULL,
    created_by character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    recipient_user_id character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    task_due_date timestamp with time zone,
    read_at timestamp with time zone,
    is_read boolean DEFAULT false,
    is_deleted boolean DEFAULT false,
    deleted_at timestamp with time zone,
    deleted_by character varying(255),
    task_recipient_id character varying(255),
    payload text,
    data jsonb
);


--
-- Name: COLUMN notifications.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.notifications.data IS 'JSON data field for storing custom notification data such as document_type, journal_id, etc.';


--
-- Name: office_server; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.office_server (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    domain_address character varying,
    local_ip character varying,
    type integer DEFAULT 1,
    active boolean DEFAULT true NOT NULL,
    server_group smallint DEFAULT 1 NOT NULL
);


--
-- Name: COLUMN office_server.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.office_server.type IS 'DEV_EXPRESS_WEB = 1
';


--
-- Name: COLUMN office_server.server_group; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.office_server.server_group IS '1 - edo uchun';


--
-- Name: org_connection_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.org_connection_type (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    type smallint DEFAULT '1'::smallint NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL
);


--
-- Name: org_contact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.org_contact (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    org_id character varying(24) NOT NULL,
    name jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    group_id character varying(24)
);


--
-- Name: organization_chief; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_chief (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    user_id character varying(24) NOT NULL,
    can_sign boolean DEFAULT false NOT NULL,
    can_resolution boolean DEFAULT false NOT NULL,
    department_id character varying(24),
    can_decontrol boolean DEFAULT false NOT NULL,
    chief_level smallint DEFAULT '0'::smallint NOT NULL,
    seen_on_leader_board boolean DEFAULT false NOT NULL
);


--
-- Name: organization_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_users (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    org_id character varying(24) NOT NULL,
    first_name character varying(64) NOT NULL,
    last_name character varying(64) NOT NULL,
    middle_name character varying(64),
    phone_number character varying(24),
    full_name character varying(255) GENERATED ALWAYS AS (TRIM(BOTH FROM (((((COALESCE(last_name, ''::character varying))::text || ' '::text) || (COALESCE(first_name, ''::character varying))::text) || ' '::text) || (COALESCE(middle_name, ''::character varying))::text))) STORED NOT NULL
);


--
-- Name: organization_weekends; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_weekends (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    weekends bigint NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    updated_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    year smallint NOT NULL
);


--
-- Name: organizational_structure; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizational_structure (
    id character varying(255) NOT NULL,
    name jsonb NOT NULL,
    type smallint DEFAULT '1'::smallint NOT NULL,
    parent_id character varying(255),
    parent_hierarchy public.ltree,
    short_name jsonb NOT NULL,
    index character varying(255),
    comment character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24),
    status smallint DEFAULT '1'::smallint,
    is_deleted boolean DEFAULT false
);


--
-- Name: organizational_structure_draft; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizational_structure_draft (
    id character varying(255) NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    data jsonb NOT NULL,
    status smallint DEFAULT '1'::smallint,
    document_number character varying(255),
    document_date date,
    file jsonb,
    comment character varying(255),
    is_deleted boolean DEFAULT false
);


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id character varying(36) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(36),
    created_at timestamp with time zone DEFAULT now(),
    created_by character varying(36),
    is_deleted boolean DEFAULT false,
    region_id character varying(36),
    type_id character varying(36),
    name_ru character varying(255),
    name_uz_cyrl character varying(255),
    address character varying(255),
    phone character varying(255),
    tin character varying(9),
    parent_id character varying(36),
    location_type character varying(255),
    relevance_type character varying(255),
    "order" integer,
    short_name_uz character varying(255),
    short_name_ru character varying(255),
    level integer,
    region_parent_id character varying(255),
    district_id character varying(24),
    prefix character varying(10),
    parent_hierarchy public.ltree,
    name_json jsonb,
    name_uz character varying(255),
    name_qqr character varying(255),
    updated_at timestamp with time zone,
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint
)
WITH (fillfactor='90');


--
-- Name: organizations_1; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations_1 (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_by character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    name_uz character varying(255) NOT NULL,
    name_ru character varying(255),
    name_uz_cyrl character varying(255),
    name_qqr character varying(225),
    region_id character varying(24),
    district_id character varying(24),
    parent_id character varying(24),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: organizations_2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations_2 (
    id character varying(36) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(36),
    created_at timestamp with time zone DEFAULT now(),
    created_by character varying(36),
    is_deleted boolean DEFAULT false,
    region_id character varying(36),
    name_ru character varying(255),
    name_uz_cyrl character varying(255),
    parent_id character varying(36),
    relevance_type character varying(255),
    "order" integer,
    short_name_uz character varying(255),
    short_name_ru character varying(255),
    level integer,
    region_parent_id character varying(255),
    sequence_index character varying(255),
    org_level_id character varying(24),
    district_id character varying(24),
    prefix character varying(10),
    parent_hierarchy public.ltree,
    name_json jsonb,
    name_uz character varying(255),
    name_qqr character varying(255),
    updated_at timestamp with time zone
)
WITH (fillfactor='90');


--
-- Name: organizations_ids; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations_ids (
    id character varying(24) NOT NULL,
    edo_id character varying(24),
    names text,
    status smallint NOT NULL
);


--
-- Name: organizations_ids_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations_ids_v2 (
    id character varying(24) NOT NULL,
    edo_id character varying(24),
    names text,
    status smallint NOT NULL
);


--
-- Name: organizations_tmp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations_tmp (
    id character varying(36),
    db_id character varying(36),
    created_at timestamp with time zone,
    created_by character varying(36),
    is_deleted boolean,
    region_id character varying(36),
    type_id character varying(36),
    name_ru character varying(255),
    name_uz_cyrl character varying(255),
    address character varying(255),
    phone character varying(255),
    tin character varying(9),
    parent_id character varying(36),
    location_type character varying(255),
    relevance_type character varying(255),
    "order" integer,
    short_name_uz character varying(255),
    short_name_ru character varying(255),
    level integer,
    region_parent_id character varying(255),
    district_id character varying(24),
    prefix character varying(10),
    parent_hierarchy public.ltree,
    name_json jsonb,
    name_uz character varying(255),
    name_qqr character varying(255),
    updated_at timestamp with time zone,
    updated_time bigint
);


--
-- Name: organizations_v2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations_v2 (
    id character varying(36) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(36),
    created_at timestamp with time zone DEFAULT now(),
    created_by character varying(36),
    is_deleted boolean DEFAULT false,
    is_active boolean DEFAULT true,
    region_id character varying(36),
    type_id character varying(36),
    name_ru character varying(255),
    name_uz character varying(255),
    address character varying(255),
    __phone character varying(255),
    __fax character varying(255),
    okpo character varying(255),
    tin character varying(9),
    parent_id character varying(36),
    okonx character varying(24),
    location_type character varying(255),
    __relevance_type character varying(255),
    __order integer,
    amount_workers integer,
    __cc_type text,
    __resolution_blank character varying(24),
    __le_id character varying(255),
    __le_nm_uz character varying(255),
    __acron_uz character varying(255),
    __reg_date date,
    __reg_no character varying(255),
    __zip character varying(255),
    __auth_capital character varying(255),
    short_name_uz character varying(255),
    short_name_ru character varying(255),
    details jsonb,
    __external_id integer,
    name_oz character varying(255),
    level integer,
    created_by_user_id text,
    created_by_department_id text,
    created_by_organization_id text,
    __scope text,
    region_parent_id character varying(255),
    __territorial_unit boolean DEFAULT false,
    sequence_index character varying(255),
    start_dt timestamp with time zone,
    org_level_id character varying(24),
    is_management boolean,
    main_parent_id character varying(24),
    district_id character varying(24),
    prefix character varying(10),
    verified boolean DEFAULT false,
    verified_data jsonb,
    parent_hierarchy public.ltree,
    name_json jsonb,
    name_uz_latn character varying(255),
    name_kaa character varying(255),
    updated_at timestamp with time zone,
    CONSTRAINT organizations_cc_type_check CHECK ((__cc_type = ANY (ARRAY['A'::text, 'B'::text])))
)
WITH (fillfactor='90');


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    worker_user_id character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    department_id character varying(24),
    user_id character varying(24),
    permission_type bigint NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    control_type smallint NOT NULL,
    updated_at timestamp with time zone
);


--
-- Name: pkcs10_until_confirm; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pkcs10_until_confirm (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    pkcs10 text NOT NULL,
    status smallint DEFAULT '0'::smallint NOT NULL,
    action_at timestamp with time zone,
    action_content text,
    subject jsonb NOT NULL,
    code character varying(10),
    state smallint DEFAULT '0'::smallint NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    key_algorithm public.key_algorithm NOT NULL,
    key_algorithm_version public.key_algorithm_version NOT NULL,
    confirmed_by_pkcs7 text,
    confirmed_by_certificate jsonb,
    form smallint NOT NULL,
    meth public.meth NOT NULL,
    path character varying(50),
    subj_user_id character varying(24),
    subj_org_id character varying(24),
    created_by character varying(24),
    created_by_json jsonb,
    is_deleted boolean DEFAULT false,
    pinpp character varying(14)
);


--
-- Name: positions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.positions (
    id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by character varying(24),
    is_deleted boolean DEFAULT false,
    name_uz character varying(255),
    name_ru character varying(255),
    name_uz_cryl character varying(255),
    order_index integer DEFAULT 0 NOT NULL,
    short_name character varying(255),
    department_ids character varying[]
);


--
-- Name: project_normative_document_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_normative_document_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: project_normative_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_normative_documents (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    document_id character varying(24),
    developed_by_db_id character varying(255),
    estimated_due_date date,
    main_recipients text[],
    normative_reg_number character varying(255),
    normative_reg_date date,
    additional_recipients text[],
    status smallint DEFAULT '1'::smallint,
    internal_doc_type_id character varying(24),
    task_id character varying,
    task_recipient_id character varying,
    recipient_department_ids character varying[],
    base character varying,
    document_year integer,
    done_at timestamp without time zone,
    done_by character varying,
    parent_document_id character varying,
    parent_hierarchy public.ltree,
    type_id character varying
);


--
-- Name: public_holidays; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.public_holidays (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    on_date date NOT NULL,
    title character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    server_id smallint NOT NULL,
    updated_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    year smallint NOT NULL
);


--
-- Name: published_doc_group_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.published_doc_group_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT now(),
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24) NOT NULL,
    action character varying,
    key_name character varying
);


--
-- Name: published_document_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.published_document_groups (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by character varying(24),
    name jsonb,
    parent_id character varying(24),
    is_deleted boolean DEFAULT false,
    parent_hierarchy public.ltree,
    internal_doc_type_ids character varying(24)[] DEFAULT '{}'::character varying[],
    sort_order integer,
    original_category_id integer
);


--
-- Name: read_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.read_logs (
    id character varying(24) NOT NULL,
    read_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    read_by character varying(24) NOT NULL,
    main_id character varying(255),
    type smallint,
    from_menu smallint
);


--
-- Name: recipient_answer_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recipient_answer_actions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    sender_db_id character varying(24) NOT NULL,
    sender_user_id character varying(24) NOT NULL,
    recipient_db_id character varying(24) NOT NULL,
    recipient_user_id character varying(24) NOT NULL,
    recipient_department_id character varying(24),
    task_id character varying(24) NOT NULL,
    recipient_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    active smallint DEFAULT '1'::smallint NOT NULL,
    state smallint DEFAULT '1'::smallint NOT NULL,
    contents character varying NOT NULL,
    files jsonb,
    action smallint NOT NULL,
    date_row date DEFAULT CURRENT_TIMESTAMP,
    deleted_by character varying(24),
    deleted_at timestamp with time zone,
    sender_department_id character varying(24),
    parent_send boolean DEFAULT false,
    copy_from_id character varying(255),
    info jsonb,
    updated_at timestamp with time zone,
    document_year smallint,
    document_send_id character varying(24),
    parent_id character varying(24),
    answer_document_id character varying(24),
    parent_send_date timestamp with time zone,
    updated_by character varying(24)
);


--
-- Name: recipient_answer_draft_until_sign; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recipient_answer_draft_until_sign (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    document_year smallint NOT NULL,
    task_id character varying(24) NOT NULL,
    recipient_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    answer_document_id character varying(24),
    type smallint
);


--
-- Name: recipient_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recipient_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: recipient_orgs_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recipient_orgs_group (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    member_orgs character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone NOT NULL,
    deleted_by character varying(24) NOT NULL,
    updated_by character varying(24) NOT NULL,
    type bigint DEFAULT '1'::bigint NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: recipients_group; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recipients_group (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    member_users character varying(24) NOT NULL,
    name character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone NOT NULL,
    deleted_by character varying(24) NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: record_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.record_history (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    record_id character varying(24) NOT NULL,
    record_type_id character varying(24) NOT NULL,
    action character varying(50) NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    attachments text[],
    organization_id character varying(24),
    metadata jsonb,
    CONSTRAINT chk_action_not_empty CHECK ((btrim((action)::text) <> ''::text)),
    CONSTRAINT chk_action_valid CHECK (((action)::text = ANY ((ARRAY['created'::character varying, 'updated'::character varying, 'deleted'::character varying, 'completed'::character varying, 'submitted'::character varying])::text[]))),
    CONSTRAINT chk_data_not_null CHECK ((data IS NOT NULL)),
    CONSTRAINT chk_record_id_not_empty CHECK ((btrim((record_id)::text) <> ''::text)),
    CONSTRAINT chk_record_type_id_not_empty CHECK ((btrim((record_type_id)::text) <> ''::text))
);


--
-- Name: TABLE record_history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.record_history IS 'Audit trail table tracking all changes to records';


--
-- Name: COLUMN record_history.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_history.id IS 'Primary key - 24 character string ID';


--
-- Name: COLUMN record_history.record_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_history.record_id IS 'Reference to the record being tracked';


--
-- Name: COLUMN record_history.record_type_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_history.record_type_id IS 'Reference to record_types table';


--
-- Name: COLUMN record_history.action; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_history.action IS 'Type of action: created, updated, deleted, completed, submitted';


--
-- Name: COLUMN record_history.created_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_history.created_by IS 'User who performed the action';


--
-- Name: COLUMN record_history.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_history.created_at IS 'Timestamp when the action occurred';


--
-- Name: COLUMN record_history.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_history.data IS 'Snapshot of record data at the time of action';


--
-- Name: COLUMN record_history.attachments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_history.attachments IS 'Snapshot of attachments at the time of action';


--
-- Name: COLUMN record_history.organization_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_history.organization_id IS 'Organization identifier for multi-tenancy';


--
-- Name: COLUMN record_history.metadata; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_history.metadata IS 'Additional metadata for change tracking (e.g., previous values)';


--
-- Name: record_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.record_types (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24),
    organization_id character varying(24),
    name text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    allow_multiple boolean DEFAULT false NOT NULL,
    allowed_owners integer DEFAULT 1 NOT NULL,
    icon text,
    editor text,
    tags text[] DEFAULT '{}'::text[] NOT NULL,
    json_schema jsonb,
    completed_json_schema jsonb,
    settings jsonb,
    file_requirement jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_name_not_empty CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT record_types_allowed_owners_check CHECK ((allowed_owners > 0))
);


--
-- Name: TABLE record_types; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.record_types IS 'Record type definitions for the application';


--
-- Name: COLUMN record_types.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_types.id IS 'Unique identifier generated from filename hash';


--
-- Name: COLUMN record_types.db_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_types.db_id IS 'Database/organization ID for multi-tenant support';


--
-- Name: COLUMN record_types.organization_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_types.organization_id IS 'Specific organization ID (nullable)';


--
-- Name: COLUMN record_types.name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_types.name IS 'Human-readable name of the record type';


--
-- Name: COLUMN record_types.is_enabled; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_types.is_enabled IS 'Whether the record type is active';


--
-- Name: COLUMN record_types.allow_multiple; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_types.allow_multiple IS 'Whether multiple instances are allowed per user';


--
-- Name: COLUMN record_types.allowed_owners; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_types.allowed_owners IS 'Number of owners allowed (positive integer)';


--
-- Name: COLUMN record_types.icon; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_types.icon IS 'Icon identifier for UI display';


--
-- Name: COLUMN record_types.editor; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_types.editor IS 'Editor component identifier';


--
-- Name: COLUMN record_types.tags; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_types.tags IS 'Array of tags for categorization';


--
-- Name: COLUMN record_types.json_schema; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_types.json_schema IS 'JSON schema for form validation';


--
-- Name: COLUMN record_types.completed_json_schema; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_types.completed_json_schema IS 'JSON schema for completed records';


--
-- Name: COLUMN record_types.settings; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_types.settings IS 'UI and validation settings';


--
-- Name: COLUMN record_types.file_requirement; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.record_types.file_requirement IS 'File attachment requirements';


--
-- Name: records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.records (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24),
    organization_id character varying(24),
    user_id character varying(24),
    record_type_id character varying(24) NOT NULL,
    pinpp character varying(14) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24),
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    completed_by character varying(24),
    deleted_at timestamp with time zone,
    deleted_by character varying(24),
    locked_at timestamp with time zone,
    locked_by character varying(24),
    synched_at timestamp with time zone,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    attachments text[],
    CONSTRAINT chk_data_not_null CHECK ((data IS NOT NULL)),
    CONSTRAINT chk_pinpp_length CHECK ((length((pinpp)::text) >= 10)),
    CONSTRAINT chk_pinpp_not_empty CHECK ((btrim((pinpp)::text) <> ''::text)),
    CONSTRAINT chk_record_type_id_not_empty CHECK ((btrim((record_type_id)::text) <> ''::text))
);


--
-- Name: TABLE records; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.records IS 'Main records table storing user data for different record types';


--
-- Name: COLUMN records.id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.id IS 'Primary key - 24 character string ID';


--
-- Name: COLUMN records.db_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.db_id IS 'Multi-tenant database identifier';


--
-- Name: COLUMN records.organization_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.organization_id IS 'Organization identifier for multi-tenancy';


--
-- Name: COLUMN records.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.user_id IS 'User who owns this record (nullable for organization records)';


--
-- Name: COLUMN records.record_type_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.record_type_id IS 'Reference to record_types table';


--
-- Name: COLUMN records.pinpp; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.pinpp IS 'Personal identification number (PINPP)';


--
-- Name: COLUMN records.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.created_at IS 'Record creation timestamp';


--
-- Name: COLUMN records.created_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.created_by IS 'User who created the record';


--
-- Name: COLUMN records.updated_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.updated_at IS 'Last update timestamp (auto-updated)';


--
-- Name: COLUMN records.completed_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.completed_at IS 'Record completion timestamp';


--
-- Name: COLUMN records.completed_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.completed_by IS 'User who completed the record';


--
-- Name: COLUMN records.deleted_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.deleted_at IS 'Soft delete timestamp';


--
-- Name: COLUMN records.deleted_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.deleted_by IS 'User who deleted the record';


--
-- Name: COLUMN records.locked_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.locked_at IS 'Record lock timestamp';


--
-- Name: COLUMN records.locked_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.locked_by IS 'User who locked the record';


--
-- Name: COLUMN records.synched_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.synched_at IS 'Last synchronization timestamp';


--
-- Name: COLUMN records.data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.data IS 'Main record data as JSONB';


--
-- Name: COLUMN records.attachments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.records.attachments IS 'Array of attachment file paths';


--
-- Name: reference_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reference_types (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    type_code character varying(100) NOT NULL,
    name_uz character varying(255),
    name_ru character varying(255),
    name_en character varying(255),
    name_cr character varying(255),
    description_uz text,
    description_ru text,
    description_en text,
    description_cr text,
    is_active boolean DEFAULT true,
    allow_hierarchy boolean DEFAULT false,
    allow_code boolean DEFAULT true,
    icon character varying(100),
    sort_order integer DEFAULT 0,
    created_by character varying(24),
    updated_by character varying(24),
    deleted_by character varying(24),
    is_deleted boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp with time zone,
    is_public boolean DEFAULT true
);


--
-- Name: TABLE reference_types; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.reference_types IS 'Stores reference type definitions. Populated from existing terms table types.';


--
-- Name: COLUMN reference_types.type_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reference_types.type_code IS 'The unique type code that will be used in terms.type column';


--
-- Name: COLUMN reference_types.is_active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reference_types.is_active IS 'If false, new references cannot be created with this type';


--
-- Name: COLUMN reference_types.allow_hierarchy; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reference_types.allow_hierarchy IS 'If true, references of this type can have parent_id';


--
-- Name: COLUMN reference_types.allow_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reference_types.allow_code IS 'If true, references of this type can have a code field';


--
-- Name: COLUMN reference_types.is_public; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reference_types.is_public IS 'If true, the reference type is publicly accessible';


--
-- Name: regions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.regions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24),
    hierarchy_key character varying(255),
    parent_id character varying(255),
    name_ru character varying(255) NOT NULL,
    name_uz character varying(255) NOT NULL,
    name_uz_cryl character varying(255) NOT NULL,
    soato character varying(7),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: reject_for_sign; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reject_for_sign (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    content character varying(2000) NOT NULL,
    document_id character varying(24) NOT NULL,
    document_year smallint NOT NULL,
    updated_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: repeatable_plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repeatable_plan (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    type character varying(100) NOT NULL,
    repetitions_count bigint NOT NULL,
    repetitions_date text NOT NULL,
    frequency character varying(100) NOT NULL,
    start_at date NOT NULL,
    end_at date NOT NULL,
    first_task_id character varying(24) NOT NULL,
    details jsonb NOT NULL,
    document_id character varying(24) NOT NULL,
    document_year smallint NOT NULL,
    updated_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT repeatable_plan_created_at_not_null CHECK ((created_at IS NOT NULL)),
    CONSTRAINT repeatable_plan_created_by_not_null CHECK ((created_by IS NOT NULL)),
    CONSTRAINT repeatable_plan_created_date_not_null CHECK ((created_date IS NOT NULL)),
    CONSTRAINT repeatable_plan_db_id_not_null CHECK ((db_id IS NOT NULL)),
    CONSTRAINT repeatable_plan_details_not_null CHECK ((details IS NOT NULL)),
    CONSTRAINT repeatable_plan_document_id_not_null CHECK ((document_id IS NOT NULL)),
    CONSTRAINT repeatable_plan_document_year_not_null CHECK ((document_year IS NOT NULL)),
    CONSTRAINT repeatable_plan_end_at_not_null CHECK ((end_at IS NOT NULL)),
    CONSTRAINT repeatable_plan_first_task_id_not_null CHECK ((first_task_id IS NOT NULL)),
    CONSTRAINT repeatable_plan_frequency_not_null CHECK ((frequency IS NOT NULL)),
    CONSTRAINT repeatable_plan_id_not_null CHECK ((id IS NOT NULL)),
    CONSTRAINT repeatable_plan_repetitions_count_not_null CHECK ((repetitions_count IS NOT NULL)),
    CONSTRAINT repeatable_plan_repetitions_date_not_null CHECK ((repetitions_date IS NOT NULL)),
    CONSTRAINT repeatable_plan_start_at_not_null CHECK ((start_at IS NOT NULL)),
    CONSTRAINT repeatable_plan_type_not_null CHECK ((type IS NOT NULL)),
    CONSTRAINT repeatable_plan_updated_at_not_null CHECK ((updated_at IS NOT NULL)),
    CONSTRAINT repeatable_plan_updated_by_not_null CHECK ((updated_by IS NOT NULL))
);


--
-- Name: repeatable_plan_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repeatable_plan_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    created_by_json jsonb NOT NULL,
    plan_id character varying(24) NOT NULL,
    old_value jsonb NOT NULL,
    new_value jsonb NOT NULL,
    actions character varying(24) NOT NULL,
    CONSTRAINT repeatable_plan_changes_actions_not_null CHECK ((actions IS NOT NULL)),
    CONSTRAINT repeatable_plan_changes_created_at_not_null CHECK ((created_at IS NOT NULL)),
    CONSTRAINT repeatable_plan_changes_created_by_json_not_null CHECK ((created_by_json IS NOT NULL)),
    CONSTRAINT repeatable_plan_changes_created_by_not_null CHECK ((created_by IS NOT NULL)),
    CONSTRAINT repeatable_plan_changes_db_id_not_null CHECK ((db_id IS NOT NULL)),
    CONSTRAINT repeatable_plan_changes_id_not_null CHECK ((id IS NOT NULL)),
    CONSTRAINT repeatable_plan_changes_new_value_not_null CHECK ((new_value IS NOT NULL)),
    CONSTRAINT repeatable_plan_changes_old_value_not_null CHECK ((old_value IS NOT NULL)),
    CONSTRAINT repeatable_plan_changes_plan_id_not_null CHECK ((plan_id IS NOT NULL))
);


--
-- Name: repeatable_task; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repeatable_task (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    due_date date NOT NULL,
    plan_id character varying(24) NOT NULL,
    activation_date date NOT NULL,
    active_task_id character varying(24),
    status character varying(100) NOT NULL,
    document_id character varying(24) NOT NULL,
    document_year smallint NOT NULL,
    updated_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT repeatable_task_activation_date_not_null CHECK ((activation_date IS NOT NULL)),
    CONSTRAINT repeatable_task_created_at_not_null CHECK ((created_at IS NOT NULL)),
    CONSTRAINT repeatable_task_created_by_not_null CHECK ((created_by IS NOT NULL)),
    CONSTRAINT repeatable_task_created_date_not_null CHECK ((created_date IS NOT NULL)),
    CONSTRAINT repeatable_task_db_id_not_null CHECK ((db_id IS NOT NULL)),
    CONSTRAINT repeatable_task_document_id_not_null CHECK ((document_id IS NOT NULL)),
    CONSTRAINT repeatable_task_document_year_not_null CHECK ((document_year IS NOT NULL)),
    CONSTRAINT repeatable_task_due_date_not_null CHECK ((due_date IS NOT NULL)),
    CONSTRAINT repeatable_task_id_not_null CHECK ((id IS NOT NULL)),
    CONSTRAINT repeatable_task_plan_id_not_null CHECK ((plan_id IS NOT NULL)),
    CONSTRAINT repeatable_task_status_not_null CHECK ((status IS NOT NULL)),
    CONSTRAINT repeatable_task_updated_at_not_null CHECK ((updated_at IS NOT NULL)),
    CONSTRAINT repeatable_task_updated_by_not_null CHECK ((updated_by IS NOT NULL))
);


--
-- Name: repeatable_task_cron; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repeatable_task_cron (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24),
    db_id character varying(24),
    status character varying(50) NOT NULL,
    document_year smallint,
    updated_by character varying(24),
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    run_date date,
    tasks_created integer DEFAULT 0,
    error_log text,
    CONSTRAINT repeatable_task_cron_created_at_not_null CHECK ((created_at IS NOT NULL)),
    CONSTRAINT repeatable_task_cron_created_date_not_null CHECK ((created_date IS NOT NULL)),
    CONSTRAINT repeatable_task_cron_id_not_null CHECK ((id IS NOT NULL)),
    CONSTRAINT repeatable_task_cron_status_not_null CHECK ((status IS NOT NULL)),
    CONSTRAINT repeatable_task_cron_updated_at_not_null CHECK ((updated_at IS NOT NULL))
);


--
-- Name: request_draft_until_sign; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.request_draft_until_sign (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying(24) NOT NULL,
    request jsonb NOT NULL,
    send jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    document_year smallint NOT NULL,
    task_id character varying(24) NOT NULL,
    recipient_id character varying(24) NOT NULL
);


--
-- Name: resolution_template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resolution_template (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    file_id character varying(24) NOT NULL,
    db_id character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24),
    title character varying(255) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    header_file_id character varying(24) NOT NULL,
    updated_by character varying(24),
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    document_type_id character varying(24),
    version smallint DEFAULT 1,
    department_ids character varying[],
    type character varying(255) DEFAULT 'resolution'::character varying NOT NULL,
    code character varying(255)
);


--
-- Name: resolution_template_body; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resolution_template_body (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24),
    department_id character varying(24),
    document_type_id character varying(24) NOT NULL,
    file_id character varying(24) NOT NULL,
    version integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    deleted_at timestamp with time zone,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: resolution_template_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.resolution_template_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: role_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value jsonb,
    old_value jsonb,
    main_id character varying(255) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: role_permission_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permission_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value jsonb,
    old_value jsonb,
    main_id character varying(24) NOT NULL,
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: role_permission_list; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permission_list (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    name character varying(255),
    code character varying(255),
    parent_id character varying(24),
    table_name character varying(255),
    parent_hierarchy public.ltree,
    type character varying(255),
    required_filters jsonb
);


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permissions (
    id character varying(24) NOT NULL,
    role_id character varying(255),
    permission_id character varying(24),
    condition_sql text DEFAULT '1=1'::text,
    condition_code jsonb,
    is_deleted boolean DEFAULT false
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name character varying(255),
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    deleted_by character varying(255),
    deleted_at timestamp with time zone
);


--
-- Name: send_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.send_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    send_id character varying(24) NOT NULL,
    recipient_id character varying(24) NOT NULL,
    task_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    old_value jsonb NOT NULL,
    new_value jsonb NOT NULL,
    change_value jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    created_by_json jsonb NOT NULL,
    document_year smallint NOT NULL
);


--
-- Name: send_to_child_access; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.send_to_child_access (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    user_id character varying(24) NOT NULL
);


--
-- Name: show_processlist; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.show_processlist AS
 SELECT pid,
    query_age,
    usename,
    query,
    state,
    backend_type,
    blocked_by,
    wait_event,
    wait_event_type,
    application_name
   FROM ( SELECT pg_stat_activity.pid,
            regexp_replace((justify_interval(age(clock_timestamp(), pg_stat_activity.query_start)))::text, '^0 years 0 mons '::text, ''::text) AS query_age,
            pg_stat_activity.usename,
            pg_stat_activity.query,
            pg_stat_activity.state,
            pg_stat_activity.backend_type,
            pg_blocking_pids(pg_stat_activity.pid) AS blocked_by,
            pg_stat_activity.wait_event,
            pg_stat_activity.wait_event_type,
            pg_stat_activity.application_name
           FROM pg_stat_activity
          WHERE ((pg_stat_activity.query <> '<IDLE>'::text) AND (pg_stat_activity.query !~~* '%pg_stat_activity%'::text) AND (pg_stat_activity.state <> 'idle'::text))) t
  ORDER BY query_age DESC;


--
-- Name: staffing_position_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staffing_position_categories (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name jsonb NOT NULL,
    code character varying(50) NOT NULL,
    order_index integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: staffing_positions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staffing_positions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(36) NOT NULL,
    unit_id character varying(24),
    position_id character varying(24) NOT NULL,
    status smallint DEFAULT 1 NOT NULL,
    max_reserves integer DEFAULT 3,
    sequence_index integer DEFAULT 0,
    is_deleted boolean DEFAULT false NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    category_id character varying(24) NOT NULL,
    rate numeric(3,2) DEFAULT 1.00 NOT NULL,
    order_number character varying(100),
    notes text,
    updated_by character varying(24),
    order_document_id character varying(24),
    attachments jsonb,
    CONSTRAINT chk_sp_status CHECK ((status = ANY (ARRAY[1, 2, 3])))
);


--
-- Name: static_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.static_data (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    file_id character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone,
    is_deleted boolean DEFAULT false NOT NULL,
    created_by character varying(24)
);


--
-- Name: static_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.static_files (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    file_id character varying(24) NOT NULL,
    code character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by character varying(24)
);


--
-- Name: static_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.static_permissions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    worker_user_id character varying(24) NOT NULL,
    db_id character varying(24) NOT NULL,
    department_id character varying(24),
    user_id character varying(24),
    permission_type integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(24) NOT NULL,
    control_type smallint GENERATED ALWAYS AS (
CASE
    WHEN (user_id IS NOT NULL) THEN 3
    WHEN ((user_id IS NULL) AND (department_id IS NOT NULL)) THEN 2
    WHEN ((user_id IS NULL) AND (department_id IS NULL) AND (db_id IS NOT NULL)) THEN 1
    ELSE NULL::integer
END) STORED,
    updated_at timestamp with time zone
);


--
-- Name: COLUMN static_permissions.permission_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.static_permissions.permission_type IS '1 - controller
5 - chancellery
10 - sektor-fishka';


--
-- Name: COLUMN static_permissions.control_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.static_permissions.control_type IS '3 - user
2  - department
1  - organization';


--
-- Name: structural_units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.structural_units (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(36) NOT NULL,
    parent_id character varying(24),
    parent_hierarchy public.ltree,
    unit_type_id character varying(24),
    depth integer DEFAULT 0 NOT NULL,
    name jsonb NOT NULL,
    short_name jsonb DEFAULT '{}'::jsonb,
    order_index integer DEFAULT 0 NOT NULL,
    sequence_index text,
    is_deleted boolean DEFAULT false NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint,
    updated_by character varying(24),
    order_number character varying(32),
    order_document_id character varying(24),
    attachments jsonb,
    CONSTRAINT chk_su_name CHECK ((name ? 'uz'::text))
);


--
-- Name: suggestions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suggestions (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    is_deleted boolean DEFAULT false,
    db_id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by character varying(24) NOT NULL,
    updated_at timestamp with time zone,
    title character varying(255) NOT NULL,
    category public.suggestion_category DEFAULT 'FEATURE_REQUEST'::public.suggestion_category NOT NULL,
    priority public.suggestion_priority DEFAULT 'MEDIUM'::public.suggestion_priority NOT NULL,
    description text NOT NULL,
    attachments jsonb[],
    status public.suggestion_status DEFAULT 'PENDING'::public.suggestion_status NOT NULL,
    rejection_reason text
);


--
-- Name: suggestions_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suggestions_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT now(),
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: sync_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sync_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    package_id uuid NOT NULL,
    entity_type smallint NOT NULL,
    entity_id character varying(24) NOT NULL
);


--
-- Name: COLUMN sync_items.entity_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sync_items.entity_type IS '1 - document,
2 - task,
3- task_recipient,
4 - task_request,
5 - task_send';


--
-- Name: sync_packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sync_packages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    package_name character varying NOT NULL,
    direction smallint DEFAULT 1 NOT NULL,
    status smallint DEFAULT 1 NOT NULL,
    total_items integer NOT NULL,
    file_id character varying(24),
    file_hash character varying,
    completed_at timestamp with time zone DEFAULT now() NOT NULL,
    last_updated_time numeric NOT NULL,
    manifest_json json,
    sync_type character varying(10) DEFAULT 'IJRO_ADM'::character varying,
    iv character varying(20),
    error_message text
);


--
-- Name: COLUMN sync_packages.direction; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sync_packages.direction IS '1 - export, 2 - import';


--
-- Name: COLUMN sync_packages.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sync_packages.status IS '1 - new,
2 - export completed to other system,
3 - import completed to this system';


--
-- Name: task_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24) NOT NULL,
    action character varying(255),
    key_name character varying(255),
    content character varying(255),
    files jsonb
);


--
-- Name: task_content_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_content_templates (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    db_id character varying(24),
    name_uz character varying(255) NOT NULL,
    name_ru character varying(255) NOT NULL,
    name_uz_lat character varying(255) NOT NULL,
    department_id character varying(24),
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: task_controllers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_controllers (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    db_id character varying(24) NOT NULL,
    controller_user_id character varying(24) NOT NULL,
    controller_department_id character varying(24) NOT NULL,
    controller_db_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    task_id character varying(24) NOT NULL,
    updated_at timestamp with time zone,
    updated_by character varying(24),
    deleted_by character varying(24),
    deleted_at timestamp with time zone,
    is_deleted boolean DEFAULT false NOT NULL,
    document_year smallint NOT NULL,
    read_at timestamp with time zone
);


--
-- Name: task_draft_until_sign; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_draft_until_sign (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    document_id character varying(24) NOT NULL,
    tasks jsonb NOT NULL,
    created_by character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    db_id character varying(24) NOT NULL,
    document_year smallint NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    document_send_id character varying(24),
    controllers jsonb,
    related_tasks jsonb,
    recipients jsonb NOT NULL,
    is_deleted boolean DEFAULT false,
    view jsonb
);


--
-- Name: task_recipients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_recipients (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    recipient_department_id character varying(24),
    recipient_db_id character varying(24) NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    done_by character varying(24),
    done_at timestamp with time zone,
    document_id character varying(24) NOT NULL,
    task_id character varying(24) NOT NULL,
    is_main boolean DEFAULT false NOT NULL,
    is_done boolean DEFAULT false,
    db_id character varying(24) NOT NULL,
    deleted_by character varying(24),
    deleted_at timestamp with time zone,
    recipient_user_id character varying(24) NOT NULL,
    updated_by character varying(24),
    updated_at timestamp with time zone,
    parent_id character varying(24),
    type smallint DEFAULT 1 NOT NULL,
    sender_user_id character varying(24) NOT NULL,
    sequence smallint,
    equally_strong smallint DEFAULT 0 NOT NULL,
    document_year smallint NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    read_at timestamp with time zone,
    document_send_id character varying(24),
    sender_department_id character varying(24),
    parent_hierarchy public.ltree,
    sender_db_id character varying(24),
    recipient_user_json jsonb GENERATED ALWAYS AS (public.get_user_by_id_json(recipient_user_id)) STORED,
    should_report_to_adm_lead smallint
);


--
-- Name: task_recipients_count; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_recipients_count (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_date date NOT NULL,
    document_type_id character varying(24) NOT NULL,
    sender_db_id character varying(24) NOT NULL,
    sender_department_id character varying(24) NOT NULL,
    sender_user_id character varying(24) NOT NULL,
    recipient_db_id character varying(24) NOT NULL,
    recipient_department_id character varying(24) DEFAULT '0character'::character varying NOT NULL,
    recipient_user_id character varying(24) DEFAULT '0character'::character varying NOT NULL,
    status bigint NOT NULL,
    total_count bigint DEFAULT '0'::bigint NOT NULL,
    type smallint DEFAULT '1'::smallint NOT NULL,
    is_main boolean DEFAULT false NOT NULL,
    document_year bigint NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    internal_doc_type_id character varying(24) DEFAULT '0character'::character varying NOT NULL
);


--
-- Name: task_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.task_requests (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    contents character varying(255) NOT NULL,
    files jsonb,
    db_id character varying(24) NOT NULL,
    recipient_id character varying(24) NOT NULL,
    task_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    deleted_by character varying(24),
    deleted_at timestamp with time zone,
    request_document_id character varying(24),
    copy_from_id character varying(24),
    updated_at timestamp with time zone,
    document_year smallint,
    document_send_id character varying(24)
);


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tasks (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    due_date date,
    is_deleted boolean DEFAULT false NOT NULL,
    is_done boolean DEFAULT false NOT NULL,
    done_at timestamp with time zone,
    done_by character varying(24),
    db_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    content character varying,
    sender_user_id character varying(24),
    parent_id character varying(24),
    pa_task_id character varying(24),
    deleted_by character varying(24),
    deleted_at timestamp with time zone,
    sender_department_id character varying(24),
    type smallint DEFAULT '1'::smallint NOT NULL,
    label_ids character varying(24)[],
    sequence bigint,
    updated_at timestamp with time zone,
    document_year smallint,
    status smallint DEFAULT 1 NOT NULL,
    document_send_id character varying(24),
    is_controlled boolean DEFAULT false NOT NULL,
    parent_hierarchy public.ltree,
    comment character varying(255),
    commented_at date,
    should_report_to_adm_lead smallint,
    point_number character varying
);


--
-- Name: tasks_count; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tasks_count (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    sender_db_id character varying(24) NOT NULL,
    sender_user_id character varying(24) NOT NULL,
    sender_department_id character varying(24) NOT NULL,
    created_date date NOT NULL,
    due_date date NOT NULL,
    is_done boolean NOT NULL,
    done_date date NOT NULL,
    type smallint NOT NULL,
    document_year smallint NOT NULL,
    total_count bigint NOT NULL,
    document_type_id character varying(24) NOT NULL,
    internal_doc_type_id character varying(24) NOT NULL
);


--
-- Name: tasks_for_sign; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tasks_for_sign (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date NOT NULL,
    created_by character varying(24) NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    db_id character varying(24) NOT NULL,
    document_id character varying(24) NOT NULL,
    sender_db_id character varying(24) NOT NULL,
    sender_department_id character varying(24) NOT NULL,
    sender_user_id character varying(24) NOT NULL,
    recipient_db_id character varying(24) NOT NULL,
    recipient_department_id character varying(24) NOT NULL,
    recipient_user_id character varying(24) NOT NULL,
    content character varying(2048) NOT NULL,
    sign_id character varying(24) NOT NULL,
    due_date date NOT NULL,
    details jsonb NOT NULL,
    status bigint DEFAULT '0'::bigint NOT NULL,
    action_at timestamp with time zone NOT NULL,
    action_by character varying(24) NOT NULL,
    reject_id character varying(24) NOT NULL,
    corrector_user_id character varying(24) NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    document_year smallint NOT NULL
);


--
-- Name: temporary_accepted_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.temporary_accepted_tasks (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    task_id character varying(255) NOT NULL,
    due_date date NOT NULL,
    content character varying(255),
    "current_user" json,
    is_deleted boolean DEFAULT false
);


--
-- Name: terms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.terms (
    id character varying(24) NOT NULL,
    name_uz character varying(500),
    name_ru character varying(500),
    name_en character varying(500),
    name_cr character varying(500),
    parent_id character varying(24),
    code character varying(50),
    created_by character varying(24),
    updated_by character varying(24),
    deleted_by character varying(24),
    is_deleted boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone,
    reference_type_id character varying(24)
);


--
-- Name: COLUMN terms.reference_type_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.terms.reference_type_id IS 'Foreign key to reference_types table. Type information is stored only in reference_types, not duplicated in terms. Use JOIN with reference_types to get type_code as type in queries.';


--
-- Name: terms_fixed; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.terms_fixed (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name_uz character varying(500),
    name_ru character varying(500),
    name_en character varying(500),
    name_cr character varying(500),
    type character varying(50) NOT NULL,
    created_by character varying(24),
    updated_by character varying(24),
    deleted_by character varying(24),
    is_deleted boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp without time zone,
    code character varying(50),
    parent_id character varying(24)
);


--
-- Name: terms_stage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.terms_stage (
    old_id character varying(24),
    name_uz character varying(500),
    name_ru character varying(500),
    name_en character varying(500),
    name_cr character varying(500),
    type character varying(50),
    created_by character varying(24),
    updated_by character varying(24),
    deleted_by character varying(24),
    is_deleted boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    code character varying(50),
    old_parent_id character varying(24),
    new_id character varying(24)
);


--
-- Name: unit_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.unit_types (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    name_uz character varying(100) NOT NULL,
    name_ru character varying(100) NOT NULL,
    name_en character varying(100),
    icon character varying(10),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: upper_organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upper_organizations (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by character varying(24) NOT NULL,
    parent_org_id character varying(24) NOT NULL,
    child_org_id character varying(24) NOT NULL,
    curator_user_id character varying(24) NOT NULL,
    curator_department_id character varying(24) NOT NULL,
    updated_by character varying(24) NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: user_changes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_changes (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_deleted boolean DEFAULT false,
    new_value text,
    old_value text,
    main_id character varying(24),
    action character varying(255),
    key_name character varying(255)
);


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    created_by character varying(24),
    created_at timestamp with time zone DEFAULT now(),
    user_id character varying(24),
    role_id character varying(24)
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    verified boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_date date DEFAULT CURRENT_TIMESTAMP NOT NULL,
    first_name character varying(32) NOT NULL,
    last_name character varying(32) NOT NULL,
    middle_name character varying(32),
    gender character varying(24),
    birthday date,
    username character varying(24),
    password character varying(255),
    last_auth timestamp with time zone,
    created_by character varying(24),
    db_id character varying(24) NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    department_id character varying(24),
    position_id character varying(24),
    full_name character varying GENERATED ALWAYS AS (TRIM(BOTH FROM (((((COALESCE(last_name, ''::character varying))::text || ' '::text) || (COALESCE(first_name, ''::character varying))::text) || ' '::text) || (COALESCE(middle_name, ''::character varying))::text))) STORED,
    sequence_index text,
    status smallint DEFAULT 1,
    block_id character varying(24) DEFAULT '689342bf6f046e37f7d20b53'::character varying,
    personal_phone character varying(13),
    corporate_phone character varying(13),
    image_json json,
    passport_number character varying(255),
    updated_time bigint DEFAULT ((EXTRACT(epoch FROM clock_timestamp()) * (1000000)::numeric))::bigint NOT NULL,
    must_change_password boolean DEFAULT false NOT NULL,
    pc_phone character varying(255),
    personal_code character varying,
    public_key text,
    parent_department_id character varying(24),
    pinpp character varying(14),
    pinpp_hash text GENERATED ALWAYS AS (
CASE
    WHEN (pinpp IS NOT NULL) THEN encode(public.digest((pinpp)::text, 'sha256'::text), 'hex'::text)
    ELSE NULL::text
END) STORED,
    priority_index integer,
    reception_number character varying(255)
);


--
-- Name: vacations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vacations (
    id character varying(24) NOT NULL,
    user_id character varying(24) NOT NULL,
    department_id character varying(24),
    position_id character varying(24),
    document_id character varying(24),
    schedule_year integer NOT NULL,
    leave_type character varying(50) DEFAULT 'annual_paid'::character varying NOT NULL,
    work_year_from date,
    work_year_to date,
    from_date date NOT NULL,
    to_date date NOT NULL,
    actual_from_date date,
    actual_to_date date,
    approval_status character varying(50) DEFAULT 'draft'::character varying NOT NULL,
    approval_step smallint DEFAULT 0 NOT NULL,
    approved_by_department_head character varying(24),
    approved_at_department_head timestamp without time zone,
    approved_by_hr character varying(24),
    approved_at_hr timestamp without time zone,
    approved_by_org_head character varying(24),
    approved_at_org_head timestamp without time zone,
    status character varying(50) DEFAULT 'unscheduled'::character varying NOT NULL,
    comments text,
    days_count integer,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying(24),
    updated_by character varying(24),
    is_deleted boolean DEFAULT false
);


--
-- Name: TABLE vacations; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.vacations IS 'Employee vacation records';


--
-- Name: COLUMN vacations.user_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vacations.user_id IS 'Reference to users table';


--
-- Name: COLUMN vacations.department_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vacations.department_id IS 'Reference to departments table';


--
-- Name: COLUMN vacations.position_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vacations.position_id IS 'Reference to positions table';


--
-- Name: COLUMN vacations.document_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vacations.document_id IS 'Reference to documents table (basis document)';


--
-- Name: COLUMN vacations.schedule_year; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vacations.schedule_year IS 'Calendar year for schedule grouping/filtering (usually derived from from_date)';


--
-- Name: COLUMN vacations.leave_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vacations.leave_type IS 'Type of leave (annual paid, unpaid, study, maternity, sick, etc.)';


--
-- Name: COLUMN vacations.work_year_from; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vacations.work_year_from IS 'Work year start date (ish yili boshlanishi)';


--
-- Name: COLUMN vacations.work_year_to; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vacations.work_year_to IS 'Work year end date (ish yili tugashi)';


--
-- Name: COLUMN vacations.actual_from_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vacations.actual_from_date IS 'Actual vacation start date';


--
-- Name: COLUMN vacations.actual_to_date; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vacations.actual_to_date IS 'Actual vacation end date';


--
-- Name: COLUMN vacations.approval_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vacations.approval_status IS 'Approval status (draft/pending/approved/rejected/cancelled)';


--
-- Name: COLUMN vacations.approval_step; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vacations.approval_step IS 'Approval step: 0=draft, 1=dept_head, 2=hr, 3=org_head';


--
-- Name: COLUMN vacations.status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vacations.status IS 'Status: unscheduled, scheduled, in_progress, declined, pending';


--
-- Name: COLUMN vacations.days_count; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vacations.days_count IS 'Number of vacation days (auto-calculated or manual)';


--
-- Name: watermark_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.watermark_logs (
    id character varying(24) DEFAULT public.generate_object_id() NOT NULL,
    db_id character varying(24) NOT NULL,
    watermark_code character varying(8) DEFAULT public.generate_watermark_code() NOT NULL,
    document_id character varying(24) NOT NULL,
    file_id character varying(24) NOT NULL,
    file_json jsonb NOT NULL,
    user_id character varying(24) NOT NULL,
    view_timestamp timestamp with time zone DEFAULT now() NOT NULL,
    ip_address character varying(45) NOT NULL,
    referrer_url character varying(500),
    user_agent text NOT NULL,
    device_type character varying(50),
    device_os character varying(100),
    browser character varying(100),
    browser_version character varying(50),
    screen_resolution character varying(20),
    access_token text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE watermark_logs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.watermark_logs IS 'Audit trail for XDFU secret document access with unique watermark codes for leak investigation';


--
-- Name: COLUMN watermark_logs.watermark_code; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watermark_logs.watermark_code IS 'Unique 8-character watermark code (Base32-Crockford)';


--
-- Name: COLUMN watermark_logs.file_json; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watermark_logs.file_json IS 'Complete file metadata snapshot';


--
-- Name: COLUMN watermark_logs.view_timestamp; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watermark_logs.view_timestamp IS 'Timestamp when watermark was generated and document viewed';


--
-- Name: COLUMN watermark_logs.ip_address; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watermark_logs.ip_address IS 'IPv4 or IPv6 address';


--
-- Name: COLUMN watermark_logs.referrer_url; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watermark_logs.referrer_url IS 'Page URL where request originated from';


--
-- Name: COLUMN watermark_logs.user_agent; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watermark_logs.user_agent IS 'Full user agent string from browser';


--
-- Name: COLUMN watermark_logs.device_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watermark_logs.device_type IS 'mobile, desktop, tablet';


--
-- Name: COLUMN watermark_logs.device_os; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watermark_logs.device_os IS 'Operating system (Windows, MacOS, Linux, Android, iOS)';


--
-- Name: COLUMN watermark_logs.browser; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watermark_logs.browser IS 'Browser name (Chrome, Firefox, Safari, Edge)';


--
-- Name: COLUMN watermark_logs.browser_version; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watermark_logs.browser_version IS 'Browser version';


--
-- Name: COLUMN watermark_logs.screen_resolution; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watermark_logs.screen_resolution IS 'Screen resolution e.g., 1920x1080';


--
-- Name: COLUMN watermark_logs.access_token; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watermark_logs.access_token IS 'JWT access token used for authentication';


--
-- Name: COLUMN watermark_logs.metadata; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.watermark_logs.metadata IS 'Flexible field for future expansion';


--
-- Name: generate_certificate; Type: TABLE; Schema: uzcrypto; Owner: -
--

CREATE TABLE uzcrypto.generate_certificate (
    id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    pkcs10 text,
    certificate text NOT NULL,
    pinpp text NOT NULL,
    serial character varying(24),
    subject jsonb,
    is_deleted boolean DEFAULT false,
    type smallint,
    hash character varying(64),
    status smallint DEFAULT '100'::smallint,
    agent text,
    token_id character varying(24),
    issuer jsonb,
    not_before timestamp with time zone,
    not_after timestamp with time zone,
    db_id character varying(24),
    created_by character varying(24),
    issuer_id character varying(24),
    register_request_id character varying(24),
    is_prolonged boolean DEFAULT false,
    prolonged_at timestamp with time zone,
    key_algorithm public.key_algorithm DEFAULT 'uzdst2'::public.key_algorithm,
    key_algorithm_version public.key_algorithm_version DEFAULT '1.2.860.3.15.1.1.2.1'::public.key_algorithm_version,
    meth public.meth DEFAULT 'set_key'::public.meth,
    form smallint DEFAULT '0'::smallint,
    path character varying(100)
);


--
-- Name: TABLE generate_certificate; Type: COMMENT; Schema: uzcrypto; Owner: -
--

COMMENT ON TABLE uzcrypto.generate_certificate IS 'CRL_REASON_CERTIFICATE_NOT_REVOKED - 100, CRL_REASON_UNSPECIFIED - 0, CRL_REASON_KEY_COMPROMISE - 1, CRL_REASON_CA_COMPROMISE - 2, CRL_REASON_AFFILIATION_CHANGED - 3, CRL_REASON_SUPERSEDED - 4, CRL_REASON_CESSATION_OF_OPERATION - 5, CRL_REASON_CERTIFICATE_HOLD - 6';


--
-- Name: trusted_issuers; Type: TABLE; Schema: uzcrypto; Owner: -
--

CREATE TABLE uzcrypto.trusted_issuers (
    id character varying(24) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    title character varying(255),
    certificate text NOT NULL,
    is_deleted boolean DEFAULT false,
    our boolean DEFAULT false NOT NULL,
    parent_id character varying(24),
    not_after date,
    not_before date,
    issuer jsonb,
    subject jsonb,
    "limit" integer,
    private_key text
);


--
-- Name: COLUMN trusted_issuers.id; Type: COMMENT; Schema: uzcrypto; Owner: -
--

COMMENT ON COLUMN uzcrypto.trusted_issuers.id IS 'Primary key';


--
-- Name: COLUMN trusted_issuers.created_at; Type: COMMENT; Schema: uzcrypto; Owner: -
--

COMMENT ON COLUMN uzcrypto.trusted_issuers.created_at IS 'Record creation timestamp';


--
-- Name: COLUMN trusted_issuers.title; Type: COMMENT; Schema: uzcrypto; Owner: -
--

COMMENT ON COLUMN uzcrypto.trusted_issuers.title IS 'Issuer title';


--
-- Name: COLUMN trusted_issuers.certificate; Type: COMMENT; Schema: uzcrypto; Owner: -
--

COMMENT ON COLUMN uzcrypto.trusted_issuers.certificate IS 'Certificate content';


--
-- Name: COLUMN trusted_issuers.is_deleted; Type: COMMENT; Schema: uzcrypto; Owner: -
--

COMMENT ON COLUMN uzcrypto.trusted_issuers.is_deleted IS 'Soft delete flag';


--
-- Name: COLUMN trusted_issuers.our; Type: COMMENT; Schema: uzcrypto; Owner: -
--

COMMENT ON COLUMN uzcrypto.trusted_issuers.our IS 'Indicates if it is our issuer';


--
-- Name: COLUMN trusted_issuers.parent_id; Type: COMMENT; Schema: uzcrypto; Owner: -
--

COMMENT ON COLUMN uzcrypto.trusted_issuers.parent_id IS 'Reference to parent issuer';


--
-- Name: COLUMN trusted_issuers.not_after; Type: COMMENT; Schema: uzcrypto; Owner: -
--

COMMENT ON COLUMN uzcrypto.trusted_issuers.not_after IS 'Certificate expiration date';


--
-- Name: COLUMN trusted_issuers.not_before; Type: COMMENT; Schema: uzcrypto; Owner: -
--

COMMENT ON COLUMN uzcrypto.trusted_issuers.not_before IS 'Certificate start date';


--
-- Name: COLUMN trusted_issuers.issuer; Type: COMMENT; Schema: uzcrypto; Owner: -
--

COMMENT ON COLUMN uzcrypto.trusted_issuers.issuer IS 'Issuer information in JSON';


--
-- Name: COLUMN trusted_issuers.subject; Type: COMMENT; Schema: uzcrypto; Owner: -
--

COMMENT ON COLUMN uzcrypto.trusted_issuers.subject IS 'Subject information in JSON';


--
-- Name: COLUMN trusted_issuers."limit"; Type: COMMENT; Schema: uzcrypto; Owner: -
--

COMMENT ON COLUMN uzcrypto.trusted_issuers."limit" IS 'Limit value';


--
-- Name: COLUMN trusted_issuers.private_key; Type: COMMENT; Schema: uzcrypto; Owner: -
--

COMMENT ON COLUMN uzcrypto.trusted_issuers.private_key IS 'Private key content';


--
-- Name: audit_cleanup_log_2026_02_11 audit_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_cleanup_log_2026_02_11 ALTER COLUMN audit_id SET DEFAULT nextval('public.audit_cleanup_log_2026_02_11_audit_id_seq'::regclass);


--
-- Name: category_mappings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_mappings ALTER COLUMN id SET DEFAULT nextval('public.category_mappings_id_seq'::regclass);


--
-- Name: knex_migrations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knex_migrations ALTER COLUMN id SET DEFAULT nextval('public.knex_migrations_id_seq'::regclass);


--
-- Name: knex_migrations_lock index; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knex_migrations_lock ALTER COLUMN index SET DEFAULT nextval('public.knex_migrations_lock_index_seq'::regclass);


--
-- Name: migration_progress id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migration_progress ALTER COLUMN id SET DEFAULT nextval('public.migration_progress_id_seq'::regclass);


--
-- Name: organization_types id_by_bit_length; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_types ALTER COLUMN id_by_bit_length SET DEFAULT nextval('public.organization_types_id_by_bit_length_seq'::regclass);


--
-- Name: access_tokens access_tokens_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.access_tokens
    ADD CONSTRAINT access_tokens_pkey PRIMARY KEY (id);


--
-- Name: agreement_group_member agreement_group_member_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.agreement_group_member
    ADD CONSTRAINT agreement_group_member_pkey PRIMARY KEY (id);


--
-- Name: agreement_group agreement_group_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.agreement_group
    ADD CONSTRAINT agreement_group_pkey PRIMARY KEY (id);


--
-- Name: appeal_forms appeal_forms_code_value_key; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.appeal_forms
    ADD CONSTRAINT appeal_forms_code_value_key UNIQUE (code_value);


--
-- Name: appeal_forms appeal_forms_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.appeal_forms
    ADD CONSTRAINT appeal_forms_pkey PRIMARY KEY (id);


--
-- Name: appeal_incoming_place appeal_incoming_place_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.appeal_incoming_place
    ADD CONSTRAINT appeal_incoming_place_pkey PRIMARY KEY (id);


--
-- Name: apps apps_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.apps
    ADD CONSTRAINT apps_pkey PRIMARY KEY (id);


--
-- Name: auth_keys auth_keys_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.auth_keys
    ADD CONSTRAINT auth_keys_pkey PRIMARY KEY (id);


--
-- Name: content_template content_template_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.content_template
    ADD CONSTRAINT content_template_pkey PRIMARY KEY (id);


--
-- Name: corrector corrector_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.corrector
    ADD CONSTRAINT corrector_pkey PRIMARY KEY (id);


--
-- Name: country country_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (id);


--
-- Name: delivery_type_changes delivery_type_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.delivery_type_changes
    ADD CONSTRAINT delivery_type_changes_pkey PRIMARY KEY (id);


--
-- Name: delivery_type delivery_type_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.delivery_type
    ADD CONSTRAINT delivery_type_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: deputy_senator_request_documents deputy_senator_request_documents_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.deputy_senator_request_documents
    ADD CONSTRAINT deputy_senator_request_documents_pkey PRIMARY KEY (id);


--
-- Name: directly_sent_docs directly_sent_docs_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.directly_sent_docs
    ADD CONSTRAINT directly_sent_docs_pkey PRIMARY KEY (id);


--
-- Name: document_agreement_changes document_agreement_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_agreement_changes
    ADD CONSTRAINT document_agreement_changes_pkey PRIMARY KEY (id);


--
-- Name: document_agreement document_agreement_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_agreement
    ADD CONSTRAINT document_agreement_pkey PRIMARY KEY (id);


--
-- Name: document_appeal document_appeal_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_appeal
    ADD CONSTRAINT document_appeal_pkey PRIMARY KEY (id);


--
-- Name: document_business_trip_changes document_business_trip_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_business_trip_changes
    ADD CONSTRAINT document_business_trip_changes_pkey PRIMARY KEY (id);


--
-- Name: document_business_trip document_business_trip_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_business_trip
    ADD CONSTRAINT document_business_trip_pkey PRIMARY KEY (id);


--
-- Name: document_changes document_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_changes
    ADD CONSTRAINT document_changes_pkey PRIMARY KEY (id);


--
-- Name: document_files_version document_files_version_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_files_version
    ADD CONSTRAINT document_files_version_pkey PRIMARY KEY (id);


--
-- Name: document_flow document_flow_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_flow
    ADD CONSTRAINT document_flow_pkey PRIMARY KEY (id);


--
-- Name: document_numbers document_numbers_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_numbers
    ADD CONSTRAINT document_numbers_pkey PRIMARY KEY (id);


--
-- Name: document_outgoing_changes document_outgoing_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_outgoing_changes
    ADD CONSTRAINT document_outgoing_changes_pkey PRIMARY KEY (id);


--
-- Name: document_outgoing document_outgoing_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_outgoing
    ADD CONSTRAINT document_outgoing_pkey PRIMARY KEY (id);


--
-- Name: document_permissions document_permissions_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_permissions
    ADD CONSTRAINT document_permissions_pkey PRIMARY KEY (id);


--
-- Name: document_qr_code document_qr_code_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_qr_code
    ADD CONSTRAINT document_qr_code_pkey PRIMARY KEY (id);


--
-- Name: document_read_logs document_read_logs_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_read_logs
    ADD CONSTRAINT document_read_logs_pkey PRIMARY KEY (id);


--
-- Name: document_read_logs document_read_logs_read_by_document_id_key; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_read_logs
    ADD CONSTRAINT document_read_logs_read_by_document_id_key UNIQUE (read_by, document_id);


--
-- Name: document_receiver_groups_for_send_sign_changes document_receiver_groups_for_send_sign_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_receiver_groups_for_send_sign_changes
    ADD CONSTRAINT document_receiver_groups_for_send_sign_changes_pkey PRIMARY KEY (id);


--
-- Name: document_receiver_groups_for_send_sign document_receiver_groups_for_send_sign_name_is_deleted_key; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_receiver_groups_for_send_sign
    ADD CONSTRAINT document_receiver_groups_for_send_sign_name_is_deleted_key UNIQUE (name, is_deleted);


--
-- Name: document_receiver_groups_for_send_sign document_receiver_groups_for_send_sign_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_receiver_groups_for_send_sign
    ADD CONSTRAINT document_receiver_groups_for_send_sign_pkey PRIMARY KEY (id);


--
-- Name: document_send_changes document_send_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_send_changes
    ADD CONSTRAINT document_send_changes_pkey PRIMARY KEY (id);


--
-- Name: document_send document_send_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_send
    ADD CONSTRAINT document_send_pkey PRIMARY KEY (id);


--
-- Name: document_send_signature_changes document_send_signature_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_send_signature_changes
    ADD CONSTRAINT document_send_signature_changes_pkey PRIMARY KEY (id);


--
-- Name: document_send_signature document_send_signature_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_send_signature
    ADD CONSTRAINT document_send_signature_pkey PRIMARY KEY (id);


--
-- Name: document_signers document_signers_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_signers
    ADD CONSTRAINT document_signers_pkey PRIMARY KEY (id);


--
-- Name: document_subject_changes document_subject_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_subject_changes
    ADD CONSTRAINT document_subject_changes_pkey PRIMARY KEY (id);


--
-- Name: document_subject document_subject_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_subject
    ADD CONSTRAINT document_subject_pkey PRIMARY KEY (id);


--
-- Name: document_types document_types_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.document_types
    ADD CONSTRAINT document_types_pkey PRIMARY KEY (id);


--
-- Name: documents_count documents_count_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.documents_count
    ADD CONSTRAINT documents_count_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: docx_file_annotations docx_file_annotations_file_id_key; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.docx_file_annotations
    ADD CONSTRAINT docx_file_annotations_file_id_key UNIQUE (file_id);


--
-- Name: docx_file_annotations docx_file_annotations_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.docx_file_annotations
    ADD CONSTRAINT docx_file_annotations_pkey PRIMARY KEY (id);


--
-- Name: download_logs download_logs_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.download_logs
    ADD CONSTRAINT download_logs_pkey PRIMARY KEY (id);


--
-- Name: draft_agreements draft_agreements_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.draft_agreements
    ADD CONSTRAINT draft_agreements_pkey PRIMARY KEY (id);


--
-- Name: drawing_journal_number_changes drawing_journal_number_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.drawing_journal_number_changes
    ADD CONSTRAINT drawing_journal_number_changes_pkey PRIMARY KEY (id);


--
-- Name: drawing_journal_number_gen drawing_journal_number_gen_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.drawing_journal_number_gen
    ADD CONSTRAINT drawing_journal_number_gen_pkey PRIMARY KEY (id);


--
-- Name: execution_control_tabs execution_control_tabs_name_is_deleted_key; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.execution_control_tabs
    ADD CONSTRAINT execution_control_tabs_name_is_deleted_key UNIQUE (name, is_deleted);


--
-- Name: execution_control_tabs execution_control_tabs_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.execution_control_tabs
    ADD CONSTRAINT execution_control_tabs_pkey PRIMARY KEY (id);


--
-- Name: failed_logs failed_logs_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.failed_logs
    ADD CONSTRAINT failed_logs_pkey PRIMARY KEY (id);


--
-- Name: favorite_organizations favorite_organizations_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.favorite_organizations
    ADD CONSTRAINT favorite_organizations_pkey PRIMARY KEY (id);


--
-- Name: favorite_tasks favorite_tasks_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.favorite_tasks
    ADD CONSTRAINT favorite_tasks_pkey PRIMARY KEY (id);


--
-- Name: file_host file_host_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.file_host
    ADD CONSTRAINT file_host_pkey PRIMARY KEY (id);


--
-- Name: files files_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (id);


--
-- Name: fraction_members fraction_members_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.fraction_members
    ADD CONSTRAINT fraction_members_pkey PRIMARY KEY (id);


--
-- Name: generate_journal_number_change generate_journal_number_change_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.generate_journal_number_change
    ADD CONSTRAINT generate_journal_number_change_pkey PRIMARY KEY (id);


--
-- Name: generate_journal_number_list generate_journal_number_list_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.generate_journal_number_list
    ADD CONSTRAINT generate_journal_number_list_pkey PRIMARY KEY (id);


--
-- Name: generate_journal_number generate_journal_number_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.generate_journal_number
    ADD CONSTRAINT generate_journal_number_pkey PRIMARY KEY (id);


--
-- Name: incoming_document_changes incoming_document_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.incoming_document_changes
    ADD CONSTRAINT incoming_document_changes_pkey PRIMARY KEY (id);


--
-- Name: incoming_documents incoming_documents_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.incoming_documents
    ADD CONSTRAINT incoming_documents_pkey PRIMARY KEY (id);


--
-- Name: inner_document_type inner_document_type_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.inner_document_type
    ADD CONSTRAINT inner_document_type_pkey PRIMARY KEY (id);


--
-- Name: internal_doc_type_changes internal_doc_type_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.internal_doc_type_changes
    ADD CONSTRAINT internal_doc_type_changes_pkey PRIMARY KEY (id);


--
-- Name: internal_doc_types internal_doc_types_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.internal_doc_types
    ADD CONSTRAINT internal_doc_types_pkey PRIMARY KEY (id);


--
-- Name: internal_document_changes internal_document_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.internal_document_changes
    ADD CONSTRAINT internal_document_changes_pkey PRIMARY KEY (id);


--
-- Name: internal_documents internal_documents_document_id_key; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.internal_documents
    ADD CONSTRAINT internal_documents_document_id_key UNIQUE (document_id);


--
-- Name: internal_documents internal_documents_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.internal_documents
    ADD CONSTRAINT internal_documents_pkey PRIMARY KEY (id);


--
-- Name: journal_changes journal_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.journal_changes
    ADD CONSTRAINT journal_changes_pkey PRIMARY KEY (id);


--
-- Name: journal journal_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.journal
    ADD CONSTRAINT journal_pkey PRIMARY KEY (id);


--
-- Name: kafka_processes kafka_processes_data_topic_key; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.kafka_processes
    ADD CONSTRAINT kafka_processes_data_topic_key UNIQUE (data, topic);


--
-- Name: kafka_processes kafka_processes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.kafka_processes
    ADD CONSTRAINT kafka_processes_pkey PRIMARY KEY (id);


--
-- Name: knex_migrations_lock knex_migrations_lock_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.knex_migrations_lock
    ADD CONSTRAINT knex_migrations_lock_pkey PRIMARY KEY (index);


--
-- Name: knex_migrations knex_migrations_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.knex_migrations
    ADD CONSTRAINT knex_migrations_pkey PRIMARY KEY (id);


--
-- Name: kpi_failed_transactions kpi_failed_transactions_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.kpi_failed_transactions
    ADD CONSTRAINT kpi_failed_transactions_pkey PRIMARY KEY (id);


--
-- Name: kpi_transactions kpi_transactions_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.kpi_transactions
    ADD CONSTRAINT kpi_transactions_pkey PRIMARY KEY (id);


--
-- Name: labels labels_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.labels
    ADD CONSTRAINT labels_pkey PRIMARY KEY (id);


--
-- Name: linked_document linked_document_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.linked_document
    ADD CONSTRAINT linked_document_pkey PRIMARY KEY (id);


--
-- Name: members members_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: newspapers newspapers_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.newspapers
    ADD CONSTRAINT newspapers_pkey PRIMARY KEY (id);


--
-- Name: normative_document_changes normative_document_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.normative_document_changes
    ADD CONSTRAINT normative_document_changes_pkey PRIMARY KEY (id);


--
-- Name: normative_documents normative_documents_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.normative_documents
    ADD CONSTRAINT normative_documents_pkey PRIMARY KEY (id);


--
-- Name: normative_legal_docs_tasks normative_legal_docs_tasks_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.normative_legal_docs_tasks
    ADD CONSTRAINT normative_legal_docs_tasks_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: org_connection_type org_connection_type_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.org_connection_type
    ADD CONSTRAINT org_connection_type_pkey PRIMARY KEY (id);


--
-- Name: org_contact org_contact_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.org_contact
    ADD CONSTRAINT org_contact_pkey PRIMARY KEY (id);


--
-- Name: organization_chief organization_chief_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.organization_chief
    ADD CONSTRAINT organization_chief_pkey PRIMARY KEY (id);


--
-- Name: organization_types organization_types_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.organization_types
    ADD CONSTRAINT organization_types_pkey PRIMARY KEY (id);


--
-- Name: organization_weekends organization_weekends_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.organization_weekends
    ADD CONSTRAINT organization_weekends_pkey PRIMARY KEY (id);


--
-- Name: organizations_1 organizations_1_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.organizations_1
    ADD CONSTRAINT organizations_1_pkey PRIMARY KEY (id);


--
-- Name: organizations_2 organizations_2_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.organizations_2
    ADD CONSTRAINT organizations_2_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: pkcs10_until_confirm pkcs10_until_confirm_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.pkcs10_until_confirm
    ADD CONSTRAINT pkcs10_until_confirm_pkey PRIMARY KEY (id);


--
-- Name: positions positions_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.positions
    ADD CONSTRAINT positions_pkey PRIMARY KEY (id);


--
-- Name: public_holidays public_holidays_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.public_holidays
    ADD CONSTRAINT public_holidays_pkey PRIMARY KEY (id);


--
-- Name: published_doc_group_changes published_doc_group_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.published_doc_group_changes
    ADD CONSTRAINT published_doc_group_changes_pkey PRIMARY KEY (id);


--
-- Name: published_document_groups published_document_groups_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.published_document_groups
    ADD CONSTRAINT published_document_groups_pkey PRIMARY KEY (id);


--
-- Name: read_logs read_logs_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.read_logs
    ADD CONSTRAINT read_logs_pkey PRIMARY KEY (id);


--
-- Name: recipient_answer_actions recipient_answer_actions_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.recipient_answer_actions
    ADD CONSTRAINT recipient_answer_actions_pkey PRIMARY KEY (id);


--
-- Name: recipient_answer_draft_until_sign recipient_answer_draft_until_sign_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.recipient_answer_draft_until_sign
    ADD CONSTRAINT recipient_answer_draft_until_sign_pkey PRIMARY KEY (id);


--
-- Name: recipient_changes recipient_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.recipient_changes
    ADD CONSTRAINT recipient_changes_pkey PRIMARY KEY (id);


--
-- Name: recipient_orgs_group recipient_orgs_group_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.recipient_orgs_group
    ADD CONSTRAINT recipient_orgs_group_pkey PRIMARY KEY (id);


--
-- Name: recipients_group recipients_group_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.recipients_group
    ADD CONSTRAINT recipients_group_pkey PRIMARY KEY (id);


--
-- Name: regions regions_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (id);


--
-- Name: reject_for_sign reject_for_sign_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.reject_for_sign
    ADD CONSTRAINT reject_for_sign_pkey PRIMARY KEY (id);


--
-- Name: repeatable_plan_changes repeatable_plan_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.repeatable_plan_changes
    ADD CONSTRAINT repeatable_plan_changes_pkey PRIMARY KEY (id);


--
-- Name: repeatable_plan repeatable_plan_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.repeatable_plan
    ADD CONSTRAINT repeatable_plan_pkey PRIMARY KEY (id);


--
-- Name: repeatable_task_cron repeatable_task_cron_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.repeatable_task_cron
    ADD CONSTRAINT repeatable_task_cron_pkey PRIMARY KEY (id);


--
-- Name: repeatable_task repeatable_task_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.repeatable_task
    ADD CONSTRAINT repeatable_task_pkey PRIMARY KEY (id);


--
-- Name: request_draft_until_sign request_draft_until_sign_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.request_draft_until_sign
    ADD CONSTRAINT request_draft_until_sign_pkey PRIMARY KEY (id);


--
-- Name: resolution_template_changes resolution_template_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.resolution_template_changes
    ADD CONSTRAINT resolution_template_changes_pkey PRIMARY KEY (id);


--
-- Name: resolution_template resolution_template_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.resolution_template
    ADD CONSTRAINT resolution_template_pkey PRIMARY KEY (id);


--
-- Name: role_changes role_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.role_changes
    ADD CONSTRAINT role_changes_pkey PRIMARY KEY (id);


--
-- Name: role_permission_changes role_permission_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.role_permission_changes
    ADD CONSTRAINT role_permission_changes_pkey PRIMARY KEY (id);


--
-- Name: role_permission_list role_permission_list_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.role_permission_list
    ADD CONSTRAINT role_permission_list_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: senate_committee_members senate_committee_members_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.senate_committee_members
    ADD CONSTRAINT senate_committee_members_pkey PRIMARY KEY (id);


--
-- Name: send_changes send_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.send_changes
    ADD CONSTRAINT send_changes_pkey PRIMARY KEY (id);


--
-- Name: send_to_child_access send_to_child_access_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.send_to_child_access
    ADD CONSTRAINT send_to_child_access_pkey PRIMARY KEY (id);


--
-- Name: task_changes task_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.task_changes
    ADD CONSTRAINT task_changes_pkey PRIMARY KEY (id);


--
-- Name: task_content_templates task_content_templates_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.task_content_templates
    ADD CONSTRAINT task_content_templates_pkey PRIMARY KEY (id);


--
-- Name: task_controllers task_controllers_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.task_controllers
    ADD CONSTRAINT task_controllers_pkey PRIMARY KEY (id);


--
-- Name: task_draft_until_sign task_draft_until_sign_document_send_id_key; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.task_draft_until_sign
    ADD CONSTRAINT task_draft_until_sign_document_send_id_key UNIQUE (document_send_id);


--
-- Name: task_draft_until_sign task_draft_until_sign_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.task_draft_until_sign
    ADD CONSTRAINT task_draft_until_sign_pkey PRIMARY KEY (id);


--
-- Name: task_recipients_count task_recipients_count_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.task_recipients_count
    ADD CONSTRAINT task_recipients_count_pkey PRIMARY KEY (id);


--
-- Name: task_recipients task_recipients_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.task_recipients
    ADD CONSTRAINT task_recipients_pkey PRIMARY KEY (id);


--
-- Name: task_requests task_requests_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.task_requests
    ADD CONSTRAINT task_requests_pkey PRIMARY KEY (id);


--
-- Name: tasks_count tasks_count_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.tasks_count
    ADD CONSTRAINT tasks_count_pkey PRIMARY KEY (id);


--
-- Name: tasks_for_sign tasks_for_sign_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.tasks_for_sign
    ADD CONSTRAINT tasks_for_sign_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: temporary_accepted_tasks temporary_accepted_tasks_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.temporary_accepted_tasks
    ADD CONSTRAINT temporary_accepted_tasks_pkey PRIMARY KEY (id);


--
-- Name: upper_organizations upper_organizations_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.upper_organizations
    ADD CONSTRAINT upper_organizations_pkey PRIMARY KEY (id);


--
-- Name: user_changes user_changes_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.user_changes
    ADD CONSTRAINT user_changes_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: archive; Owner: -
--

ALTER TABLE ONLY archive.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: direction direction_pk; Type: CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.direction
    ADD CONSTRAINT direction_pk PRIMARY KEY (id);


--
-- Name: documents documents_pk; Type: CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.documents
    ADD CONSTRAINT documents_pk PRIMARY KEY (id);


--
-- Name: task_recipients task_recipients_pk; Type: CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_recipients
    ADD CONSTRAINT task_recipients_pk PRIMARY KEY (id);


--
-- Name: task_requests task_requests_pk; Type: CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_requests
    ADD CONSTRAINT task_requests_pk PRIMARY KEY (id);


--
-- Name: task_send task_send_pk; Type: CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_send
    ADD CONSTRAINT task_send_pk PRIMARY KEY (id);


--
-- Name: tasks tasks_pk; Type: CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.tasks
    ADD CONSTRAINT tasks_pk PRIMARY KEY (id);


--
-- Name: access_tokens access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_tokens
    ADD CONSTRAINT access_tokens_pkey PRIMARY KEY (id);


--
-- Name: adm_leaders adm_leaders_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_leaders
    ADD CONSTRAINT adm_leaders_pk PRIMARY KEY (id);


--
-- Name: agreement_group_member agreement_group_member_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agreement_group_member
    ADD CONSTRAINT agreement_group_member_pkey PRIMARY KEY (id);


--
-- Name: agreement_group agreement_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agreement_group
    ADD CONSTRAINT agreement_group_pkey PRIMARY KEY (id);


--
-- Name: ai_suggestions ai_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ai_suggestions
    ADD CONSTRAINT ai_suggestions_pkey PRIMARY KEY (id);


--
-- Name: app_constants app_constants_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_constants
    ADD CONSTRAINT app_constants_name_key UNIQUE (name);


--
-- Name: assignments assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: async_processor async_processor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.async_processor
    ADD CONSTRAINT async_processor_pkey PRIMARY KEY (id);


--
-- Name: audit_cleanup_log_2026_02_11 audit_cleanup_log_2026_02_11_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_cleanup_log_2026_02_11
    ADD CONSTRAINT audit_cleanup_log_2026_02_11_pkey PRIMARY KEY (audit_id);


--
-- Name: auth_keys auth_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_keys
    ADD CONSTRAINT auth_keys_pkey PRIMARY KEY (id);


--
-- Name: background_check_batches background_check_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_check_batches
    ADD CONSTRAINT background_check_batches_pkey PRIMARY KEY (id);


--
-- Name: background_checks background_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_checks
    ADD CONSTRAINT background_checks_pkey PRIMARY KEY (id);


--
-- Name: building_blocks building_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_blocks
    ADD CONSTRAINT building_blocks_pkey PRIMARY KEY (id);


--
-- Name: category_mappings category_mappings_category_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_mappings
    ADD CONSTRAINT category_mappings_category_id_unique UNIQUE (category_id);


--
-- Name: category_mappings category_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_mappings
    ADD CONSTRAINT category_mappings_pkey PRIMARY KEY (id);


--
-- Name: static_permissions chancellery_permission_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_permissions
    ADD CONSTRAINT chancellery_permission_pk PRIMARY KEY (id);


--
-- Name: content_template content_template_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_template
    ADD CONSTRAINT content_template_pkey PRIMARY KEY (id);


--
-- Name: corrector corrector_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.corrector
    ADD CONSTRAINT corrector_pkey PRIMARY KEY (id);


--
-- Name: country country_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (id);


--
-- Name: delivery_type_changes delivery_type_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_type_changes
    ADD CONSTRAINT delivery_type_changes_pkey PRIMARY KEY (id);


--
-- Name: delivery_type delivery_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_type
    ADD CONSTRAINT delivery_type_pkey PRIMARY KEY (id);


--
-- Name: department_structure department_structure_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_structure
    ADD CONSTRAINT department_structure_pkey PRIMARY KEY (id);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);


--
-- Name: doc_outgoing_resend doc_outgoing_resend_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doc_outgoing_resend
    ADD CONSTRAINT doc_outgoing_resend_pk PRIMARY KEY (id);


--
-- Name: document_actions document_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_actions
    ADD CONSTRAINT document_actions_pkey PRIMARY KEY (id);


--
-- Name: document_aggreement_with_organization_changes document_aggreement_with_organization_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_aggreement_with_organization_changes
    ADD CONSTRAINT document_aggreement_with_organization_changes_pkey PRIMARY KEY (id);


--
-- Name: document_aggreement_with_organizations document_aggreement_with_organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_aggreement_with_organizations
    ADD CONSTRAINT document_aggreement_with_organizations_pkey PRIMARY KEY (id);


--
-- Name: document_agreement_changes document_agreement_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_agreement_changes
    ADD CONSTRAINT document_agreement_changes_pkey PRIMARY KEY (id);


--
-- Name: document_agreement document_agreement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_agreement
    ADD CONSTRAINT document_agreement_pkey PRIMARY KEY (id);


--
-- Name: document_business_trip_changes document_business_trip_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_business_trip_changes
    ADD CONSTRAINT document_business_trip_changes_pkey PRIMARY KEY (id);


--
-- Name: document_business_trip document_business_trip_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_business_trip
    ADD CONSTRAINT document_business_trip_pkey PRIMARY KEY (id);


--
-- Name: document_changes document_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_changes
    ADD CONSTRAINT document_changes_pkey PRIMARY KEY (id);


--
-- Name: document_files_version document_files_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_files_version
    ADD CONSTRAINT document_files_version_pkey PRIMARY KEY (id);


--
-- Name: document_flow document_flow_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_flow
    ADD CONSTRAINT document_flow_pkey PRIMARY KEY (id);


--
-- Name: document_numbers document_numbers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_numbers
    ADD CONSTRAINT document_numbers_pkey PRIMARY KEY (id);


--
-- Name: document_outgoing_changes document_outgoing_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_outgoing_changes
    ADD CONSTRAINT document_outgoing_changes_pkey PRIMARY KEY (id);


--
-- Name: document_outgoing document_outgoing_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_outgoing
    ADD CONSTRAINT document_outgoing_pkey PRIMARY KEY (id);


--
-- Name: document_permissions document_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_permissions
    ADD CONSTRAINT document_permissions_pkey PRIMARY KEY (id);


--
-- Name: document_qr_code document_qr_code_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_qr_code
    ADD CONSTRAINT document_qr_code_pkey PRIMARY KEY (id);


--
-- Name: document_read_logs document_read_logs_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_read_logs
    ADD CONSTRAINT document_read_logs_pk UNIQUE (read_by, document_id);


--
-- Name: document_read_logs document_read_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_read_logs
    ADD CONSTRAINT document_read_logs_pkey PRIMARY KEY (id);


--
-- Name: document_receiver_groups_for_send_sign_changes document_receiver_groups_for_send_sign_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_receiver_groups_for_send_sign_changes
    ADD CONSTRAINT document_receiver_groups_for_send_sign_changes_pkey PRIMARY KEY (id);


--
-- Name: document_receiver_groups_for_send_sign document_receiver_groups_for_send_sign_name_is_deleted_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_receiver_groups_for_send_sign
    ADD CONSTRAINT document_receiver_groups_for_send_sign_name_is_deleted_unique UNIQUE (name, is_deleted);


--
-- Name: document_receiver_groups_for_send_sign document_receiver_groups_for_send_sign_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_receiver_groups_for_send_sign
    ADD CONSTRAINT document_receiver_groups_for_send_sign_pkey PRIMARY KEY (id);


--
-- Name: document_send document_resolution_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send
    ADD CONSTRAINT document_resolution_pkey PRIMARY KEY (id);


--
-- Name: document_send_changes document_send_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_changes
    ADD CONSTRAINT document_send_changes_pkey PRIMARY KEY (id);


--
-- Name: document_send_signature_changes document_send_signature_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_signature_changes
    ADD CONSTRAINT document_send_signature_changes_pkey PRIMARY KEY (id);


--
-- Name: document_send_staged document_send_staged_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_staged
    ADD CONSTRAINT document_send_staged_pkey PRIMARY KEY (id);


--
-- Name: document_send_signature document_signature_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_signature
    ADD CONSTRAINT document_signature_pkey PRIMARY KEY (id);


--
-- Name: document_signers document_signers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_signers
    ADD CONSTRAINT document_signers_pkey PRIMARY KEY (id);


--
-- Name: document_signers_staged document_signers_staged_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_signers_staged
    ADD CONSTRAINT document_signers_staged_pkey PRIMARY KEY (id);


--
-- Name: document_subject_changes document_subject_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_subject_changes
    ADD CONSTRAINT document_subject_changes_pkey PRIMARY KEY (id);


--
-- Name: document_subject document_subject_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_subject
    ADD CONSTRAINT document_subject_pkey PRIMARY KEY (id);


--
-- Name: document_types document_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_types
    ADD CONSTRAINT document_types_pkey PRIMARY KEY (id);


--
-- Name: documents_count documents_count_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents_count
    ADD CONSTRAINT documents_count_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: docx_file_annotations docx_file_annotations_file_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.docx_file_annotations
    ADD CONSTRAINT docx_file_annotations_file_id_unique UNIQUE (file_id);


--
-- Name: docx_file_annotations docx_file_annotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.docx_file_annotations
    ADD CONSTRAINT docx_file_annotations_pkey PRIMARY KEY (id);


--
-- Name: download_logs download_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.download_logs
    ADD CONSTRAINT download_logs_pkey PRIMARY KEY (id);


--
-- Name: drawing_journal_number_changes drawing_journal_number_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drawing_journal_number_changes
    ADD CONSTRAINT drawing_journal_number_changes_pkey PRIMARY KEY (id);


--
-- Name: drawing_journal_number_gen drawing_journal_number_gen_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drawing_journal_number_gen
    ADD CONSTRAINT drawing_journal_number_gen_pkey PRIMARY KEY (id);


--
-- Name: duty_schedule_group duty_schedule_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.duty_schedule_group
    ADD CONSTRAINT duty_schedule_group_pkey PRIMARY KEY (id);


--
-- Name: duty_schedule_groups_users duty_schedule_groups_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.duty_schedule_groups_users
    ADD CONSTRAINT duty_schedule_groups_users_pkey PRIMARY KEY (id);


--
-- Name: egov_tokens egov_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.egov_tokens
    ADD CONSTRAINT egov_tokens_pkey PRIMARY KEY (id);


--
-- Name: event_handlers event_handlers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_handlers
    ADD CONSTRAINT event_handlers_pkey PRIMARY KEY (id);


--
-- Name: event_pool event_pool_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_pool
    ADD CONSTRAINT event_pool_pkey PRIMARY KEY (id);


--
-- Name: excel_templates excel_templates_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.excel_templates
    ADD CONSTRAINT excel_templates_pk PRIMARY KEY (id);


--
-- Name: execution_control_tabs execution_control_tabs_name_is_deleted_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.execution_control_tabs
    ADD CONSTRAINT execution_control_tabs_name_is_deleted_unique UNIQUE (name, is_deleted);


--
-- Name: execution_control_tabs execution_control_tabs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.execution_control_tabs
    ADD CONSTRAINT execution_control_tabs_pkey PRIMARY KEY (id);


--
-- Name: execution_flow execution_flow_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.execution_flow
    ADD CONSTRAINT execution_flow_pk PRIMARY KEY (id);


--
-- Name: execution_flow execution_flow_pk_2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.execution_flow
    ADD CONSTRAINT execution_flow_pk_2 UNIQUE (data_id);


--
-- Name: failed_logs failed_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.failed_logs
    ADD CONSTRAINT failed_logs_pkey PRIMARY KEY (id);


--
-- Name: favorite_organizations favorite_organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_organizations
    ADD CONSTRAINT favorite_organizations_pkey PRIMARY KEY (id);


--
-- Name: favorite_tasks favorite_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_tasks
    ADD CONSTRAINT favorite_tasks_pkey PRIMARY KEY (id);


--
-- Name: file_host file_host_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.file_host
    ADD CONSTRAINT file_host_pkey PRIMARY KEY (id);


--
-- Name: files files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (id);


--
-- Name: fraction_members fraction_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fraction_members
    ADD CONSTRAINT fraction_members_pkey PRIMARY KEY (id);


--
-- Name: generate_journal_number_change generate_journal_number_change_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generate_journal_number_change
    ADD CONSTRAINT generate_journal_number_change_pkey PRIMARY KEY (id);


--
-- Name: generate_journal_number_list generate_journal_number_list_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generate_journal_number_list
    ADD CONSTRAINT generate_journal_number_list_pkey PRIMARY KEY (id);


--
-- Name: generate_journal_number generate_journal_number_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generate_journal_number
    ADD CONSTRAINT generate_journal_number_pkey PRIMARY KEY (id);


--
-- Name: guest_documents guest_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_documents
    ADD CONSTRAINT guest_documents_pkey PRIMARY KEY (id);


--
-- Name: guest_request_approvals guest_request_approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_request_approvals
    ADD CONSTRAINT guest_request_approvals_pkey PRIMARY KEY (id);


--
-- Name: guest_request_logs guest_request_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_request_logs
    ADD CONSTRAINT guest_request_logs_pkey PRIMARY KEY (id);


--
-- Name: guest_requests guest_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_requests
    ADD CONSTRAINT guest_requests_pkey PRIMARY KEY (id);


--
-- Name: guests guests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guests
    ADD CONSTRAINT guests_pkey PRIMARY KEY (id);


--
-- Name: incoming_document_changes incoming_document_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoming_document_changes
    ADD CONSTRAINT incoming_document_changes_pkey PRIMARY KEY (id);


--
-- Name: incoming_documents incoming_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoming_documents
    ADD CONSTRAINT incoming_documents_pkey PRIMARY KEY (id);


--
-- Name: initiative_doc_recipients initiative_doc_recipients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.initiative_doc_recipients
    ADD CONSTRAINT initiative_doc_recipients_pkey PRIMARY KEY (id);


--
-- Name: initiative_nhh_docs initiative_nhh_docs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.initiative_nhh_docs
    ADD CONSTRAINT initiative_nhh_docs_pkey PRIMARY KEY (id);


--
-- Name: inner_document_type inner_document_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inner_document_type
    ADD CONSTRAINT inner_document_type_pkey PRIMARY KEY (id);


--
-- Name: integration_settings integration_settings_method_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integration_settings
    ADD CONSTRAINT integration_settings_method_name_key UNIQUE (method_name);


--
-- Name: integration_settings integration_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integration_settings
    ADD CONSTRAINT integration_settings_pkey PRIMARY KEY (id);


--
-- Name: integrations integrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations
    ADD CONSTRAINT integrations_pkey PRIMARY KEY (id);


--
-- Name: internal_doc_type_changes internal_doc_type_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_doc_type_changes
    ADD CONSTRAINT internal_doc_type_changes_pkey PRIMARY KEY (id);


--
-- Name: internal_doc_types internal_doc_types_code_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_doc_types
    ADD CONSTRAINT internal_doc_types_code_unique UNIQUE (code);


--
-- Name: internal_doc_types internal_doc_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_doc_types
    ADD CONSTRAINT internal_doc_types_pkey PRIMARY KEY (id);


--
-- Name: internal_document_changes internal_document_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_document_changes
    ADD CONSTRAINT internal_document_changes_pkey PRIMARY KEY (id);


--
-- Name: internal_document_flow_events internal_document_flow_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_document_flow_events
    ADD CONSTRAINT internal_document_flow_events_pkey PRIMARY KEY (id);


--
-- Name: internal_document_flow_state internal_document_flow_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_document_flow_state
    ADD CONSTRAINT internal_document_flow_state_pkey PRIMARY KEY (root_document_id);


--
-- Name: internal_document_relations internal_document_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_document_relations
    ADD CONSTRAINT internal_document_relations_pkey PRIMARY KEY (id);


--
-- Name: internal_documents internal_documents_document_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_documents
    ADD CONSTRAINT internal_documents_document_id_unique UNIQUE (document_id);


--
-- Name: internal_documents internal_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_documents
    ADD CONSTRAINT internal_documents_pkey PRIMARY KEY (id);


--
-- Name: internal_notifications internal_notifications_event_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_notifications
    ADD CONSTRAINT internal_notifications_event_id_key UNIQUE (event_id);


--
-- Name: internal_notifications internal_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_notifications
    ADD CONSTRAINT internal_notifications_pkey PRIMARY KEY (id);


--
-- Name: journal_changes journal_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_changes
    ADD CONSTRAINT journal_changes_pkey PRIMARY KEY (id);


--
-- Name: journal journal_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal
    ADD CONSTRAINT journal_pkey PRIMARY KEY (id);


--
-- Name: kafka_processes kafka_processes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kafka_processes
    ADD CONSTRAINT kafka_processes_pkey PRIMARY KEY (id);


--
-- Name: knex_migrations_lock knex_migrations_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knex_migrations_lock
    ADD CONSTRAINT knex_migrations_lock_pkey PRIMARY KEY (index);


--
-- Name: knex_migrations knex_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knex_migrations
    ADD CONSTRAINT knex_migrations_pkey PRIMARY KEY (id);


--
-- Name: kpi_failed_transactions kpi_failed_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kpi_failed_transactions
    ADD CONSTRAINT kpi_failed_transactions_pkey PRIMARY KEY (id);


--
-- Name: kpi_transactions kpi_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kpi_transactions
    ADD CONSTRAINT kpi_transactions_pkey PRIMARY KEY (id);


--
-- Name: labels labels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.labels
    ADD CONSTRAINT labels_pkey PRIMARY KEY (id);


--
-- Name: library_book_files library_book_files_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.library_book_files
    ADD CONSTRAINT library_book_files_pk PRIMARY KEY (id);


--
-- Name: library_books library_books_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.library_books
    ADD CONSTRAINT library_books_pk PRIMARY KEY (id_library_books);


--
-- Name: linked_document linked_document_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linked_document
    ADD CONSTRAINT linked_document_pkey PRIMARY KEY (id);


--
-- Name: members members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: migration_progress migration_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migration_progress
    ADD CONSTRAINT migration_progress_pkey PRIMARY KEY (id);


--
-- Name: news news_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news
    ADD CONSTRAINT news_pkey PRIMARY KEY (id);


--
-- Name: news_read_logs news_read_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_read_logs
    ADD CONSTRAINT news_read_logs_pkey PRIMARY KEY (id);


--
-- Name: newspapers newspapers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspapers
    ADD CONSTRAINT newspapers_pkey PRIMARY KEY (id);


--
-- Name: nhh_agreement_changes nhh_agreement_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_agreement_changes
    ADD CONSTRAINT nhh_agreement_changes_pkey PRIMARY KEY (id);


--
-- Name: nhh_agreements nhh_agreements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_agreements
    ADD CONSTRAINT nhh_agreements_pkey PRIMARY KEY (id);


--
-- Name: nhh_kpi nhh_kpi_document_kpi_type_depth_user; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi
    ADD CONSTRAINT nhh_kpi_document_kpi_type_depth_user UNIQUE (document_id, kpi_type, depth, user_id);


--
-- Name: nhh_kpi_document_setting_changes nhh_kpi_document_setting_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_document_setting_changes
    ADD CONSTRAINT nhh_kpi_document_setting_changes_pkey PRIMARY KEY (id);


--
-- Name: nhh_kpi_document_settings nhh_kpi_document_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_document_settings
    ADD CONSTRAINT nhh_kpi_document_settings_pkey PRIMARY KEY (id);


--
-- Name: nhh_kpi_due_date_ranges nhh_kpi_due_date_ranges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_due_date_ranges
    ADD CONSTRAINT nhh_kpi_due_date_ranges_pkey PRIMARY KEY (id);


--
-- Name: nhh_kpi nhh_kpi_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi
    ADD CONSTRAINT nhh_kpi_pkey PRIMARY KEY (id);


--
-- Name: nhh_kpi_records nhh_kpi_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_records
    ADD CONSTRAINT nhh_kpi_records_pkey PRIMARY KEY (id);


--
-- Name: nhh_kpi_type_changes nhh_kpi_type_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_type_changes
    ADD CONSTRAINT nhh_kpi_type_changes_pkey PRIMARY KEY (id);


--
-- Name: nhh_kpi_type_config_changes nhh_kpi_type_config_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_type_config_changes
    ADD CONSTRAINT nhh_kpi_type_config_changes_pkey PRIMARY KEY (id);


--
-- Name: nhh_kpi_type_configs nhh_kpi_type_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_type_configs
    ADD CONSTRAINT nhh_kpi_type_configs_pkey PRIMARY KEY (id);


--
-- Name: nhh_kpi_type_group_changes nhh_kpi_type_group_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_type_group_changes
    ADD CONSTRAINT nhh_kpi_type_group_changes_pkey PRIMARY KEY (id);


--
-- Name: nhh_kpi_type_groups nhh_kpi_type_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_type_groups
    ADD CONSTRAINT nhh_kpi_type_groups_pkey PRIMARY KEY (id);


--
-- Name: nhh_kpi_types nhh_kpi_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_types
    ADD CONSTRAINT nhh_kpi_types_pkey PRIMARY KEY (id);


--
-- Name: nhh_kpi_version_changes nhh_kpi_version_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_version_changes
    ADD CONSTRAINT nhh_kpi_version_changes_pkey PRIMARY KEY (id);


--
-- Name: nhh_kpi_versions nhh_kpi_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_versions
    ADD CONSTRAINT nhh_kpi_versions_pkey PRIMARY KEY (id);


--
-- Name: nomenclatures nomenclatures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nomenclatures
    ADD CONSTRAINT nomenclatures_pkey PRIMARY KEY (id);


--
-- Name: normative_doc_bases normative_doc_bases_content_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.normative_doc_bases
    ADD CONSTRAINT normative_doc_bases_content_unique UNIQUE (content);


--
-- Name: normative_doc_bases normative_doc_bases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.normative_doc_bases
    ADD CONSTRAINT normative_doc_bases_pkey PRIMARY KEY (id);


--
-- Name: normative_document_changes normative_document_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.normative_document_changes
    ADD CONSTRAINT normative_document_changes_pkey PRIMARY KEY (id);


--
-- Name: normative_documents normative_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.normative_documents
    ADD CONSTRAINT normative_documents_pkey PRIMARY KEY (id);


--
-- Name: normative_legal_docs_tasks normative_legal_docs_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.normative_legal_docs_tasks
    ADD CONSTRAINT normative_legal_docs_tasks_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: office_server office_server_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_server
    ADD CONSTRAINT office_server_pk PRIMARY KEY (id);


--
-- Name: org_connection_type org_connection_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org_connection_type
    ADD CONSTRAINT org_connection_type_pkey PRIMARY KEY (id);


--
-- Name: org_contact org_contact_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org_contact
    ADD CONSTRAINT org_contact_pkey PRIMARY KEY (id);


--
-- Name: organization_chief organization_chief_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_chief
    ADD CONSTRAINT organization_chief_pkey PRIMARY KEY (id);


--
-- Name: organization_types organization_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_types
    ADD CONSTRAINT organization_types_pkey PRIMARY KEY (id);


--
-- Name: organization_users organization_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_users
    ADD CONSTRAINT organization_users_pkey PRIMARY KEY (id);


--
-- Name: organization_weekends organization_weekends_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_weekends
    ADD CONSTRAINT organization_weekends_pkey PRIMARY KEY (id);


--
-- Name: organizational_structure_draft organizational_structure_draft_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizational_structure_draft
    ADD CONSTRAINT organizational_structure_draft_pkey PRIMARY KEY (id);


--
-- Name: organizational_structure organizational_structure_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizational_structure
    ADD CONSTRAINT organizational_structure_pkey PRIMARY KEY (id);


--
-- Name: organizations_ids organizations_ids_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_ids
    ADD CONSTRAINT organizations_ids_pkey PRIMARY KEY (id);


--
-- Name: organizations_ids_v2 organizations_ids_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_ids_v2
    ADD CONSTRAINT organizations_ids_v2_pkey PRIMARY KEY (id);


--
-- Name: organizations_1 organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_1
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: organizations_2 organizations_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_2
    ADD CONSTRAINT organizations_pkey1 PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey2; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey2 PRIMARY KEY (id);


--
-- Name: organizations_v2 organizations_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_v2
    ADD CONSTRAINT organizations_v2_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: pkcs10_until_confirm pkcs10_until_confirm_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pkcs10_until_confirm
    ADD CONSTRAINT pkcs10_until_confirm_pkey PRIMARY KEY (id);


--
-- Name: positions positions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.positions
    ADD CONSTRAINT positions_pkey PRIMARY KEY (id);


--
-- Name: project_normative_document_changes project_normative_document_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_normative_document_changes
    ADD CONSTRAINT project_normative_document_changes_pkey PRIMARY KEY (id);


--
-- Name: project_normative_documents project_normative_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_normative_documents
    ADD CONSTRAINT project_normative_documents_pkey PRIMARY KEY (id);


--
-- Name: public_holidays public_holidays_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_holidays
    ADD CONSTRAINT public_holidays_pkey PRIMARY KEY (id);


--
-- Name: published_doc_group_changes published_doc_group_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.published_doc_group_changes
    ADD CONSTRAINT published_doc_group_changes_pkey PRIMARY KEY (id);


--
-- Name: published_document_groups published_document_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.published_document_groups
    ADD CONSTRAINT published_document_groups_pkey PRIMARY KEY (id);


--
-- Name: read_logs read_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.read_logs
    ADD CONSTRAINT read_logs_pkey PRIMARY KEY (id);


--
-- Name: recipient_answer_draft_until_sign recipient_answer_draft_until_sign_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_draft_until_sign
    ADD CONSTRAINT recipient_answer_draft_until_sign_pkey PRIMARY KEY (id);


--
-- Name: recipient_changes recipient_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_changes
    ADD CONSTRAINT recipient_changes_pkey PRIMARY KEY (id);


--
-- Name: recipient_orgs_group recipient_orgs_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_orgs_group
    ADD CONSTRAINT recipient_orgs_group_pkey PRIMARY KEY (id);


--
-- Name: recipients_group recipients_group_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipients_group
    ADD CONSTRAINT recipients_group_pkey PRIMARY KEY (id);


--
-- Name: record_history record_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_history
    ADD CONSTRAINT record_history_pkey PRIMARY KEY (id);


--
-- Name: record_types record_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_types
    ADD CONSTRAINT record_types_pkey PRIMARY KEY (id);


--
-- Name: records records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.records
    ADD CONSTRAINT records_pkey PRIMARY KEY (id);


--
-- Name: reference_types reference_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reference_types
    ADD CONSTRAINT reference_types_pkey PRIMARY KEY (id);


--
-- Name: reference_types reference_types_type_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reference_types
    ADD CONSTRAINT reference_types_type_code_key UNIQUE (type_code);


--
-- Name: regions regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (id);


--
-- Name: reject_for_sign reject_for_sign_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reject_for_sign
    ADD CONSTRAINT reject_for_sign_pkey PRIMARY KEY (id);


--
-- Name: repeatable_plan_changes repeatable_plan_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_plan_changes
    ADD CONSTRAINT repeatable_plan_changes_pkey PRIMARY KEY (id);


--
-- Name: repeatable_plan repeatable_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_plan
    ADD CONSTRAINT repeatable_plan_pkey PRIMARY KEY (id);


--
-- Name: repeatable_task_cron repeatable_task_cron_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_task_cron
    ADD CONSTRAINT repeatable_task_cron_pkey PRIMARY KEY (id);


--
-- Name: repeatable_task repeatable_task_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_task
    ADD CONSTRAINT repeatable_task_pkey PRIMARY KEY (id);


--
-- Name: request_draft_until_sign request_draft_until_sign_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_draft_until_sign
    ADD CONSTRAINT request_draft_until_sign_pkey PRIMARY KEY (id);


--
-- Name: resolution_template_body resolution_template_body_db_id_document_type_id_version_is_dele; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resolution_template_body
    ADD CONSTRAINT resolution_template_body_db_id_document_type_id_version_is_dele UNIQUE (db_id, document_type_id, version, is_deleted);


--
-- Name: resolution_template_body resolution_template_body_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resolution_template_body
    ADD CONSTRAINT resolution_template_body_pkey PRIMARY KEY (id);


--
-- Name: resolution_template_changes resolution_template_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resolution_template_changes
    ADD CONSTRAINT resolution_template_changes_pkey PRIMARY KEY (id);


--
-- Name: resolution_template resolution_template_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resolution_template
    ADD CONSTRAINT resolution_template_pkey PRIMARY KEY (id);


--
-- Name: role_changes role_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_changes
    ADD CONSTRAINT role_changes_pkey PRIMARY KEY (id);


--
-- Name: role_permission_changes role_permission_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission_changes
    ADD CONSTRAINT role_permission_changes_pkey PRIMARY KEY (id);


--
-- Name: role_permission_list role_permission_list_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission_list
    ADD CONSTRAINT role_permission_list_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: send_changes send_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.send_changes
    ADD CONSTRAINT send_changes_pkey PRIMARY KEY (id);


--
-- Name: send_to_child_access send_to_child_access_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.send_to_child_access
    ADD CONSTRAINT send_to_child_access_pkey PRIMARY KEY (id);


--
-- Name: staffing_position_categories staffing_position_categories_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffing_position_categories
    ADD CONSTRAINT staffing_position_categories_code_key UNIQUE (code);


--
-- Name: staffing_position_categories staffing_position_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffing_position_categories
    ADD CONSTRAINT staffing_position_categories_pkey PRIMARY KEY (id);


--
-- Name: staffing_positions staffing_positions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffing_positions
    ADD CONSTRAINT staffing_positions_pkey PRIMARY KEY (id);


--
-- Name: static_data static_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_data
    ADD CONSTRAINT static_data_pkey PRIMARY KEY (id);


--
-- Name: static_files static_files_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_files
    ADD CONSTRAINT static_files_code_key UNIQUE (code);


--
-- Name: static_files static_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_files
    ADD CONSTRAINT static_files_pkey PRIMARY KEY (id);


--
-- Name: structural_units structural_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.structural_units
    ADD CONSTRAINT structural_units_pkey PRIMARY KEY (id);


--
-- Name: suggestions_changes suggestions_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suggestions_changes
    ADD CONSTRAINT suggestions_changes_pkey PRIMARY KEY (id);


--
-- Name: suggestions suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suggestions
    ADD CONSTRAINT suggestions_pkey PRIMARY KEY (id);


--
-- Name: sync_items sync_items_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sync_items
    ADD CONSTRAINT sync_items_pk PRIMARY KEY (id);


--
-- Name: sync_packages sync_packages_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sync_packages
    ADD CONSTRAINT sync_packages_pk PRIMARY KEY (id);


--
-- Name: task_changes task_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_changes
    ADD CONSTRAINT task_changes_pkey PRIMARY KEY (id);


--
-- Name: task_content_templates task_content_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_content_templates
    ADD CONSTRAINT task_content_templates_pkey PRIMARY KEY (id);


--
-- Name: task_controllers task_controllers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_controllers
    ADD CONSTRAINT task_controllers_pkey PRIMARY KEY (id);


--
-- Name: task_draft_until_sign task_draft_document_send_unique_constraint; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_draft_until_sign
    ADD CONSTRAINT task_draft_document_send_unique_constraint UNIQUE (document_send_id);


--
-- Name: task_draft_until_sign task_draft_until_sign_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_draft_until_sign
    ADD CONSTRAINT task_draft_until_sign_pkey PRIMARY KEY (id);


--
-- Name: task_recipients_count task_recipients_count_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients_count
    ADD CONSTRAINT task_recipients_count_pkey PRIMARY KEY (id);


--
-- Name: task_recipients task_recipients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients
    ADD CONSTRAINT task_recipients_pkey PRIMARY KEY (id);


--
-- Name: task_requests task_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_requests
    ADD CONSTRAINT task_requests_pkey PRIMARY KEY (id);


--
-- Name: recipient_answer_actions task_send_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT task_send_pkey PRIMARY KEY (id);


--
-- Name: tasks_count tasks_count_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_count
    ADD CONSTRAINT tasks_count_pkey PRIMARY KEY (id);


--
-- Name: tasks_for_sign tasks_for_sign_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_for_sign
    ADD CONSTRAINT tasks_for_sign_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: temporary_accepted_tasks temporary_accepted_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.temporary_accepted_tasks
    ADD CONSTRAINT temporary_accepted_tasks_pkey PRIMARY KEY (id);


--
-- Name: terms_fixed terms_fixed_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.terms_fixed
    ADD CONSTRAINT terms_fixed_pkey PRIMARY KEY (id);


--
-- Name: terms terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.terms
    ADD CONSTRAINT terms_pkey PRIMARY KEY (id);


--
-- Name: unit_types unit_types_name_uz_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unit_types
    ADD CONSTRAINT unit_types_name_uz_key UNIQUE (name_uz);


--
-- Name: unit_types unit_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unit_types
    ADD CONSTRAINT unit_types_pkey PRIMARY KEY (id);


--
-- Name: upper_organizations upper_organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upper_organizations
    ADD CONSTRAINT upper_organizations_pkey PRIMARY KEY (id);


--
-- Name: news_read_logs uq_news_read_logs_user_news; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_read_logs
    ADD CONSTRAINT uq_news_read_logs_user_news UNIQUE (user_id, news_id);


--
-- Name: nhh_kpi_due_date_ranges uq_nhh_kpi_due_date_ranges; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_due_date_ranges
    ADD CONSTRAINT uq_nhh_kpi_due_date_ranges UNIQUE (version_id, kpi_type_id);


--
-- Name: nhh_kpi_records uq_nhh_kpi_records; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_records
    ADD CONSTRAINT uq_nhh_kpi_records UNIQUE (document_id, kpi_type_id, recipient_user_id);


--
-- Name: nhh_kpi_type_configs uq_nhh_kpi_type_configs; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_type_configs
    ADD CONSTRAINT uq_nhh_kpi_type_configs UNIQUE (version_id, kpi_type_id, internal_doc_type_id);


--
-- Name: nhh_kpi_type_groups uq_nhh_kpi_type_groups_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_type_groups
    ADD CONSTRAINT uq_nhh_kpi_type_groups_key UNIQUE (key);


--
-- Name: nhh_kpi_types uq_nhh_kpi_types_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_types
    ADD CONSTRAINT uq_nhh_kpi_types_key UNIQUE (key);


--
-- Name: user_changes user_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_changes
    ADD CONSTRAINT user_changes_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vacations vacations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vacations
    ADD CONSTRAINT vacations_pkey PRIMARY KEY (id);


--
-- Name: watermark_logs watermark_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watermark_logs
    ADD CONSTRAINT watermark_logs_pkey PRIMARY KEY (id);


--
-- Name: watermark_logs watermark_logs_watermark_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watermark_logs
    ADD CONSTRAINT watermark_logs_watermark_code_key UNIQUE (watermark_code);


--
-- Name: generate_certificate generate_certificate_pkey; Type: CONSTRAINT; Schema: uzcrypto; Owner: -
--

ALTER TABLE ONLY uzcrypto.generate_certificate
    ADD CONSTRAINT generate_certificate_pkey PRIMARY KEY (id);


--
-- Name: trusted_issuers trusted_issuers_pkey; Type: CONSTRAINT; Schema: uzcrypto; Owner: -
--

ALTER TABLE ONLY uzcrypto.trusted_issuers
    ADD CONSTRAINT trusted_issuers_pkey PRIMARY KEY (id);


--
-- Name: access_tokens_created_at_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE INDEX access_tokens_created_at_idx ON archive.access_tokens USING btree (created_at DESC);


--
-- Name: access_tokens_ip_address_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE INDEX access_tokens_ip_address_idx ON archive.access_tokens USING btree (ip_address);


--
-- Name: access_tokens_user_id_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE INDEX access_tokens_user_id_idx ON archive.access_tokens USING btree (user_id DESC);


--
-- Name: document_flow_document_parent_hierarchy_arr_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE INDEX document_flow_document_parent_hierarchy_arr_idx ON archive.document_flow USING gin (document_parent_hierarchy_arr);


--
-- Name: document_send_document_id_recipient_user_id_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE UNIQUE INDEX document_send_document_id_recipient_user_id_idx ON archive.document_send USING btree (document_id, recipient_user_id) WHERE ((is_deleted IS FALSE) AND (status <> 20));


--
-- Name: docx_file_annotations_file_id_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE INDEX docx_file_annotations_file_id_idx ON archive.docx_file_annotations USING btree (file_id DESC);


--
-- Name: download_logs_created_at_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE INDEX download_logs_created_at_idx ON archive.download_logs USING btree (created_at DESC);


--
-- Name: download_logs_file_id_user_id_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE INDEX download_logs_file_id_user_id_idx ON archive.download_logs USING btree (file_id DESC, user_id DESC);


--
-- Name: generate_journal_number_db_id_journal_id_year_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE UNIQUE INDEX generate_journal_number_db_id_journal_id_year_idx ON archive.generate_journal_number USING btree (db_id, journal_id, year);


--
-- Name: internal_documents_document_id_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE INDEX internal_documents_document_id_idx ON archive.internal_documents USING btree (document_id);


--
-- Name: notifications_recipient_user_id_is_deleted_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE INDEX notifications_recipient_user_id_is_deleted_idx ON archive.notifications USING btree (recipient_user_id, is_deleted);


--
-- Name: notifications_recipient_user_id_is_deleted_is_read_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE INDEX notifications_recipient_user_id_is_deleted_is_read_idx ON archive.notifications USING btree (recipient_user_id, is_deleted, is_read);


--
-- Name: pkcs10_until_confirm_code_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE UNIQUE INDEX pkcs10_until_confirm_code_idx ON archive.pkcs10_until_confirm USING btree (code);


--
-- Name: pkcs10_until_confirm_id_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE UNIQUE INDEX pkcs10_until_confirm_id_idx ON archive.pkcs10_until_confirm USING btree (id);


--
-- Name: pkcs10_until_confirm_id_idx1; Type: INDEX; Schema: archive; Owner: -
--

CREATE UNIQUE INDEX pkcs10_until_confirm_id_idx1 ON archive.pkcs10_until_confirm USING btree (id);


--
-- Name: pkcs10_until_confirm_is_deleted_subj_user_id_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE INDEX pkcs10_until_confirm_is_deleted_subj_user_id_idx ON archive.pkcs10_until_confirm USING btree (is_deleted, subj_user_id);


--
-- Name: pkcs10_until_confirm_subj_user_id_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE INDEX pkcs10_until_confirm_subj_user_id_idx ON archive.pkcs10_until_confirm USING btree (subj_user_id);


--
-- Name: task_draft_until_sign_document_send_id_idx; Type: INDEX; Schema: archive; Owner: -
--

CREATE UNIQUE INDEX task_draft_until_sign_document_send_id_idx ON archive.task_draft_until_sign USING btree (document_send_id) WHERE (is_deleted IS FALSE);


--
-- Name: direction_id_uindex; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE UNIQUE INDEX direction_id_uindex ON president_assignments.direction USING btree (id);


--
-- Name: document_internal_order_document_id_db_id_uindex; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE UNIQUE INDEX document_internal_order_document_id_db_id_uindex ON president_assignments.document_internal_order_state USING btree (document_id, db_id);


--
-- Name: document_internal_order_state_db_id_index; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE INDEX document_internal_order_state_db_id_index ON president_assignments.document_internal_order_state USING btree (db_id);


--
-- Name: document_internal_order_state_document_id_index; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE INDEX document_internal_order_state_document_id_index ON president_assignments.document_internal_order_state USING btree (document_id);


--
-- Name: document_internal_order_state_document_id_status_index; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE INDEX document_internal_order_state_document_id_status_index ON president_assignments.document_internal_order_state USING btree (document_id, status);


--
-- Name: document_internal_order_state_status_index; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE INDEX document_internal_order_state_status_index ON president_assignments.document_internal_order_state USING btree (status);


--
-- Name: idx_document_internal_order_state_created_by; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE INDEX idx_document_internal_order_state_created_by ON president_assignments.document_internal_order_state USING btree (created_by);


--
-- Name: idx_tasks_created_by; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE INDEX idx_tasks_created_by ON president_assignments.tasks USING btree (created_by);


--
-- Name: idx_tasks_db_id; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE INDEX idx_tasks_db_id ON president_assignments.tasks USING btree (db_id);


--
-- Name: idx_tasks_done_by; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE INDEX idx_tasks_done_by ON president_assignments.tasks USING btree (done_by);


--
-- Name: idx_tasks_id_is_deleted; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE INDEX idx_tasks_id_is_deleted ON president_assignments.tasks USING btree (id, is_deleted);


--
-- Name: tasks__updated_time; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE INDEX tasks__updated_time ON president_assignments.tasks USING btree (updated_time DESC);


--
-- Name: tasks_document_id_index; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE INDEX tasks_document_id_index ON president_assignments.tasks USING btree (document_id);


--
-- Name: tasks_due_date_index; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE INDEX tasks_due_date_index ON president_assignments.tasks USING btree (due_date DESC);


--
-- Name: tasks_id_without_deleted; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE INDEX tasks_id_without_deleted ON president_assignments.tasks USING btree (id) WHERE (is_deleted IS NOT TRUE);


--
-- Name: tasks_is_deleted_index; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE INDEX tasks_is_deleted_index ON president_assignments.tasks USING btree (is_deleted DESC);


--
-- Name: tasks_repeatable_index; Type: INDEX; Schema: president_assignments; Owner: -
--

CREATE INDEX tasks_repeatable_index ON president_assignments.tasks USING btree (repeatable);


--
-- Name: access_tokens__time; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX access_tokens__time ON public.access_tokens USING btree (created_at DESC);


--
-- Name: access_tokens__user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX access_tokens__user ON public.access_tokens USING btree (user_id DESC);


--
-- Name: access_tokens_ip_address_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX access_tokens_ip_address_index ON public.access_tokens USING btree (ip_address);


--
-- Name: category_mappings_category_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX category_mappings_category_id_index ON public.category_mappings USING btree (category_id);


--
-- Name: category_mappings_internal_doc_type_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX category_mappings_internal_doc_type_id_index ON public.category_mappings USING btree (internal_doc_type_id);


--
-- Name: category_mappings_parent_category_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX category_mappings_parent_category_id_index ON public.category_mappings USING btree (parent_category_id);


--
-- Name: chancellery_permission_id_uindex; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX chancellery_permission_id_uindex ON public.permissions USING btree (id);


--
-- Name: doc_outgoing_resend__document_year_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX doc_outgoing_resend__document_year_index ON public.doc_outgoing_resend USING btree (document_year);


--
-- Name: doc_outgoing_resend__out; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX doc_outgoing_resend__out ON public.doc_outgoing_resend USING btree (document_outgoing_id, active);


--
-- Name: doc_outgoing_resend_by_user_date_3_test; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX doc_outgoing_resend_by_user_date_3_test ON public.doc_outgoing_resend USING btree (created_by, created_at, id) WHERE ((type = 3) AND (NOT is_deleted));


--
-- Name: doc_outgoing_resend_document_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX doc_outgoing_resend_document_id_index ON public.doc_outgoing_resend USING btree (document_id DESC);


--
-- Name: doc_outgoing_resend_document_outgoing_id_document_id_abdugani; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX doc_outgoing_resend_document_outgoing_id_document_id_abdugani ON public.doc_outgoing_resend USING btree (document_outgoing_id, document_id);


--
-- Name: doc_outgoing_resend_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX doc_outgoing_resend_type_index ON public.doc_outgoing_resend USING btree (type DESC);


--
-- Name: document_actions_action_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX document_actions_action_idx ON public.document_actions USING btree (action);


--
-- Name: document_actions_document_id_action_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX document_actions_document_id_action_at_idx ON public.document_actions USING btree (document_id, action_at);


--
-- Name: document_flow_document_parent_hierarchy_arr_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX document_flow_document_parent_hierarchy_arr_index ON public.document_flow USING gin (document_parent_hierarchy_arr);


--
-- Name: document_permissions_document_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX document_permissions_document_id_index ON public.document_permissions USING btree (document_id);


--
-- Name: document_permissions_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX document_permissions_user_id_index ON public.document_permissions USING btree (user_id);


--
-- Name: document_send_document_recipient_uindex; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX document_send_document_recipient_uindex ON public.document_send USING btree (document_id, recipient_user_id) WHERE ((is_deleted IS FALSE) AND (status <> 20));


--
-- Name: docx_file_annotation_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX docx_file_annotation_file_id_index ON public.docx_file_annotations USING btree (file_id DESC);


--
-- Name: download_logs__created_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX download_logs__created_desc ON public.download_logs USING btree (created_at DESC);


--
-- Name: download_logs_file_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX download_logs_file_id_index ON public.download_logs USING btree (file_id DESC, user_id DESC);


--
-- Name: excel_templates_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX excel_templates_code_index ON public.excel_templates USING btree (code);


--
-- Name: execution_flow_data_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX execution_flow_data_id_index ON public.execution_flow USING btree (data_id);


--
-- Name: execution_flow_depth_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX execution_flow_depth_idx ON public.execution_flow USING btree (depth);


--
-- Name: execution_flow_main_document_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX execution_flow_main_document_id_index ON public.execution_flow USING btree (main_document_id);


--
-- Name: execution_flow_parent_document_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX execution_flow_parent_document_id_idx ON public.execution_flow USING btree (parent_document_id) WHERE (is_deleted = false);


--
-- Name: execution_flow_path_btree_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX execution_flow_path_btree_idx ON public.execution_flow USING btree (path);


--
-- Name: execution_flow_path_gist_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX execution_flow_path_gist_idx ON public.execution_flow USING gist (path);


--
-- Name: execution_flow_type_data_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX execution_flow_type_data_id_index ON public.execution_flow USING btree (type, data_id) WHERE (is_deleted = false);


--
-- Name: idx_asgn_list_aggregation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asgn_list_aggregation ON public.assignments USING btree (staffing_position_id, ended_at, is_deleted);


--
-- Name: idx_asgn_sp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asgn_sp ON public.assignments USING btree (staffing_position_id) WHERE ((ended_at IS NULL) AND (is_deleted = false));


--
-- Name: idx_asgn_unique_primary; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_asgn_unique_primary ON public.assignments USING btree (staffing_position_id) WHERE ((is_reserve = false) AND (ended_at IS NULL) AND (is_deleted = false));


--
-- Name: idx_asgn_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asgn_user ON public.assignments USING btree (user_id) WHERE ((ended_at IS NULL) AND (is_deleted = false));


--
-- Name: idx_background_check_batches_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_background_check_batches_created_at ON public.background_check_batches USING btree (created_at DESC);


--
-- Name: idx_background_checks_batch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_background_checks_batch_id ON public.background_checks USING btree (batch_id) WHERE (batch_id IS NOT NULL);


--
-- Name: idx_background_checks_integration_setting_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_background_checks_integration_setting_ids ON public.background_checks USING gin (integration_setting_ids);


--
-- Name: idx_bg_check_batch_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_check_batch_created_at ON public.background_check_batches USING btree (created_at);


--
-- Name: idx_bg_check_batch_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_check_batch_created_by ON public.background_check_batches USING btree (created_by);


--
-- Name: idx_bg_check_batch_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_check_batch_status ON public.background_check_batches USING btree (status);


--
-- Name: idx_bg_check_batch_sync_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_check_batch_sync_package_id ON public.background_check_batches USING btree (sync_package_id);


--
-- Name: idx_bg_checks_completed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_checks_completed_at ON public.background_checks USING btree (completed_at DESC) WHERE (completed_at IS NOT NULL);


--
-- Name: idx_bg_checks_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_checks_created_at ON public.background_checks USING btree (created_at DESC);


--
-- Name: idx_bg_checks_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_checks_created_by ON public.background_checks USING btree (created_by);


--
-- Name: idx_bg_checks_error_stage; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_checks_error_stage ON public.background_checks USING btree (error_stage) WHERE (error_stage IS NOT NULL);


--
-- Name: idx_bg_checks_external_results_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_checks_external_results_gin ON public.background_checks USING gin (external_service_results) WHERE (external_service_results IS NOT NULL);


--
-- Name: idx_bg_checks_incomplete; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_checks_incomplete ON public.background_checks USING btree (id, created_at DESC) WHERE ((status)::text <> 'completed'::text);


--
-- Name: idx_bg_checks_mapped_data_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_checks_mapped_data_gin ON public.background_checks USING gin (mapped_data) WHERE (mapped_data IS NOT NULL);


--
-- Name: idx_bg_checks_pinpp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_checks_pinpp ON public.background_checks USING btree (pinpp) WHERE (pinpp IS NOT NULL);


--
-- Name: idx_bg_checks_retryable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_checks_retryable ON public.background_checks USING btree (id, error_stage, created_at DESC) WHERE (((status)::text = 'failed'::text) AND ((error_stage)::text <> 'upsert'::text));


--
-- Name: idx_bg_checks_search_criteria_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_checks_search_criteria_gin ON public.background_checks USING gin (search_criteria);


--
-- Name: idx_bg_checks_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_checks_status ON public.background_checks USING btree (status);


--
-- Name: idx_bg_checks_status_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_checks_status_created ON public.background_checks USING btree (status, created_at DESC);


--
-- Name: idx_bg_checks_tin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_checks_tin ON public.background_checks USING btree (tin) WHERE (tin IS NOT NULL);


--
-- Name: idx_bg_checks_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_checks_updated_at ON public.background_checks USING btree (updated_at DESC);


--
-- Name: idx_bg_checks_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_checks_user_id ON public.background_checks USING btree (user_id) WHERE (user_id IS NOT NULL);


--
-- Name: idx_bg_checks_user_snapshot_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bg_checks_user_snapshot_gin ON public.background_checks USING gin ("user");


--
-- Name: idx_confirm_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_confirm_is_deleted ON public.pkcs10_until_confirm USING btree (is_deleted, subj_user_id);


--
-- Name: idx_doc_outgoing_resend_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_doc_outgoing_resend_created_by ON public.doc_outgoing_resend USING btree (created_by, type) WHERE (is_deleted IS NOT TRUE);


--
-- Name: idx_document_send_document_id_not_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_document_send_document_id_not_deleted ON public.document_send USING btree (document_id, menu_type, created_at DESC) WHERE (is_deleted = false);


--
-- Name: INDEX idx_document_send_document_id_not_deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.idx_document_send_document_id_not_deleted IS 'Optimizes lateral join for main_send in hr/list';


--
-- Name: idx_documents_nomenclature_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_documents_nomenclature_ids ON public.documents USING gin (nomenclature_ids);


--
-- Name: idx_documents_nomenclature_json; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_documents_nomenclature_json ON public.documents USING gin (nomenclature_json);


--
-- Name: idx_egov_tokens_service_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_egov_tokens_service_active ON public.egov_tokens USING btree (service_name, is_active);


--
-- Name: idx_event_handlers_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_handlers_created_at ON public.event_handlers USING btree (created_at);


--
-- Name: idx_event_handlers_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_handlers_name ON public.event_handlers USING btree (name);


--
-- Name: idx_event_pool_event_handler_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_pool_event_handler_id ON public.event_pool USING btree (event_handler_id);


--
-- Name: idx_event_pool_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_pool_event_id ON public.event_pool USING btree (event_id);


--
-- Name: idx_event_pool_event_type_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_pool_event_type_created ON public.event_pool USING btree (event_type, created_at);


--
-- Name: idx_event_pool_org_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_pool_org_created ON public.event_pool USING btree (organization_id, created_at);


--
-- Name: idx_event_pool_processed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_pool_processed ON public.event_pool USING btree (processed_at);


--
-- Name: idx_event_pool_processing; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_pool_processing ON public.event_pool USING btree (processing_at);


--
-- Name: idx_event_pool_source_system_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_pool_source_system_created ON public.event_pool USING btree (source_system, created_at);


--
-- Name: idx_event_pool_status_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_pool_status_created ON public.event_pool USING btree (processing_status, created_at);


--
-- Name: idx_event_pool_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_pool_timestamp ON public.event_pool USING btree ("timestamp");


--
-- Name: idx_event_pool_topic_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_event_pool_topic_created ON public.event_pool USING btree (topic, created_at);


--
-- Name: idx_initiative_doc_recipients_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_initiative_doc_recipients_active ON public.initiative_doc_recipients USING btree (id) WHERE (is_deleted = false);


--
-- Name: idx_initiative_doc_recipients_doc_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_initiative_doc_recipients_doc_id ON public.initiative_doc_recipients USING btree (initiative_doc_id);


--
-- Name: idx_initiative_doc_recipients_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_initiative_doc_recipients_user_id ON public.initiative_doc_recipients USING btree (recipient_user_id);


--
-- Name: idx_initiative_nhh_docs_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_initiative_nhh_docs_active ON public.initiative_nhh_docs USING btree (id) WHERE (is_deleted = false);


--
-- Name: idx_initiative_nhh_docs_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_initiative_nhh_docs_document_id ON public.initiative_nhh_docs USING btree (document_id);


--
-- Name: idx_initiative_nhh_docs_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_initiative_nhh_docs_status ON public.initiative_nhh_docs USING btree (status);


--
-- Name: idx_integration_settings_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_integration_settings_parent_id ON public.integration_settings USING btree (parent_id);


--
-- Name: idx_integrations_integration_setting_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_integrations_integration_setting_id ON public.integrations USING btree (integration_setting_id);


--
-- Name: idx_integrations_method_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_integrations_method_name ON public.integrations USING btree (method_name);


--
-- Name: idx_integrations_pinpp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_integrations_pinpp ON public.integrations USING btree (pinpp);


--
-- Name: idx_integrations_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_integrations_record_id ON public.integrations USING btree (record_id);


--
-- Name: idx_integrations_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_integrations_request_id ON public.integrations USING btree (request_id);


--
-- Name: idx_integrations_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_integrations_status ON public.integrations USING btree (status);


--
-- Name: idx_integrations_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_integrations_user_id ON public.integrations USING btree (user_id);


--
-- Name: idx_internal_doc_types_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_doc_types_code ON public.internal_doc_types USING btree (code);


--
-- Name: idx_internal_doc_types_department_ids_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_doc_types_department_ids_gin ON public.internal_doc_types USING gin (department_ids) WHERE (department_ids IS NOT NULL);


--
-- Name: idx_internal_document_flow_events_root_doc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_document_flow_events_root_doc ON public.internal_document_flow_events USING btree (root_document_id);


--
-- Name: idx_internal_document_flow_events_trigger_doc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_document_flow_events_trigger_doc ON public.internal_document_flow_events USING btree (trigger_document_id);


--
-- Name: idx_internal_document_flow_state_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_document_flow_state_status ON public.internal_document_flow_state USING btree (current_flow_status);


--
-- Name: idx_internal_document_relations_child_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_document_relations_child_id ON public.internal_document_relations USING btree (child_id);


--
-- Name: idx_internal_document_relations_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_document_relations_parent_id ON public.internal_document_relations USING btree (parent_id);


--
-- Name: idx_internal_documents_document_id_not_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_documents_document_id_not_deleted ON public.internal_documents USING btree (document_id) WHERE (is_deleted = false);


--
-- Name: INDEX idx_internal_documents_document_id_not_deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.idx_internal_documents_document_id_not_deleted IS 'Speeds up JOINs between internal_documents and documents tables';


--
-- Name: idx_internal_documents_hr_list_default_sort; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_documents_hr_list_default_sort ON public.internal_documents USING btree (is_deleted, ((viewed_at IS NULL)) DESC, document_id DESC) WHERE (is_deleted = false);


--
-- Name: INDEX idx_internal_documents_hr_list_default_sort; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.idx_internal_documents_hr_list_default_sort IS 'Optimizes default hr/list sorting: unviewed documents first, then by created_at';


--
-- Name: idx_internal_documents_status_not_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_documents_status_not_deleted ON public.internal_documents USING btree (status) WHERE (is_deleted = false);


--
-- Name: INDEX idx_internal_documents_status_not_deleted; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.idx_internal_documents_status_not_deleted IS 'Optimizes status filtering in hr/list endpoint';


--
-- Name: idx_internal_documents_viewed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_documents_viewed_at ON public.internal_documents USING btree (viewed_at) WHERE (viewed_at IS NOT NULL);


--
-- Name: idx_internal_documents_viewed_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_documents_viewed_by ON public.internal_documents USING btree (viewed_by) WHERE (viewed_by IS NOT NULL);


--
-- Name: idx_internal_notifications_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_notifications_category ON public.internal_notifications USING btree (category);


--
-- Name: idx_internal_notifications_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_notifications_created_at ON public.internal_notifications USING btree (created_at DESC);


--
-- Name: idx_internal_notifications_db_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_notifications_db_status ON public.internal_notifications USING btree (db_status);


--
-- Name: idx_internal_notifications_due_telegram; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_notifications_due_telegram ON public.internal_notifications USING btree (telegram_status, telegram_next_attempt_at) WHERE (((telegram_status)::text = 'PENDING'::text) AND (telegram_next_attempt_at IS NOT NULL));


--
-- Name: idx_internal_notifications_endpoint; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_notifications_endpoint ON public.internal_notifications USING btree (endpoint) WHERE (endpoint IS NOT NULL);


--
-- Name: idx_internal_notifications_error_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_notifications_error_code ON public.internal_notifications USING btree (error_code) WHERE (error_code IS NOT NULL);


--
-- Name: idx_internal_notifications_service_category_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_notifications_service_category_created ON public.internal_notifications USING btree (service_name, category, created_at DESC);


--
-- Name: idx_internal_notifications_service_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_notifications_service_name ON public.internal_notifications USING btree (service_name);


--
-- Name: idx_internal_notifications_severity_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_notifications_severity_created_at ON public.internal_notifications USING btree (severity, created_at DESC);


--
-- Name: idx_internal_notifications_telegram_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_internal_notifications_telegram_status ON public.internal_notifications USING btree (telegram_status);


--
-- Name: idx_news_active_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_news_active_created_at ON public.news USING btree (is_deleted, created_at);


--
-- Name: idx_news_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_news_created_by ON public.news USING btree (created_by);


--
-- Name: idx_news_db_id_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_news_db_id_deleted ON public.news USING btree (db_id, is_deleted);


--
-- Name: idx_news_read_logs_news_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_news_read_logs_news_id ON public.news_read_logs USING btree (news_id);


--
-- Name: idx_news_read_logs_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_news_read_logs_user_id ON public.news_read_logs USING btree (user_id);


--
-- Name: idx_news_read_logs_user_read_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_news_read_logs_user_read_at ON public.news_read_logs USING btree (user_id, read_at);


--
-- Name: idx_nhh_kpi_active_dates; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nhh_kpi_active_dates ON public.nhh_kpi USING btree (document_date, document_year, internal_doc_type_id) WHERE (is_active = true);


--
-- Name: idx_nhh_kpi_active_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nhh_kpi_active_lookup ON public.nhh_kpi USING btree (user_id, document_id, due_date_type) WHERE (is_active = true);


--
-- Name: idx_nhh_kpi_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nhh_kpi_created_at ON public.nhh_kpi USING btree (created_at);


--
-- Name: idx_nhh_kpi_data_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nhh_kpi_data_gin ON public.nhh_kpi USING gin (data);


--
-- Name: idx_nhh_kpi_document_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nhh_kpi_document_date ON public.nhh_kpi USING btree (document_date);


--
-- Name: idx_nhh_kpi_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nhh_kpi_document_id ON public.nhh_kpi USING btree (document_id);


--
-- Name: idx_nhh_kpi_document_kpi_type_depth_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nhh_kpi_document_kpi_type_depth_user ON public.nhh_kpi USING btree (document_id, kpi_type, depth, user_id);


--
-- Name: idx_nhh_kpi_document_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nhh_kpi_document_year ON public.nhh_kpi USING btree (document_year);


--
-- Name: idx_nhh_kpi_due_date_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nhh_kpi_due_date_type ON public.nhh_kpi USING btree (due_date_type);


--
-- Name: idx_nhh_kpi_internal_doc_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nhh_kpi_internal_doc_type_id ON public.nhh_kpi USING btree (internal_doc_type_id);


--
-- Name: idx_nhh_kpi_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nhh_kpi_is_active ON public.nhh_kpi USING btree (is_active);


--
-- Name: idx_nhh_kpi_recipient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nhh_kpi_recipient_id ON public.nhh_kpi USING btree (recipient_id);


--
-- Name: idx_nhh_kpi_type_score; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nhh_kpi_type_score ON public.nhh_kpi USING btree (document_id, type, score) WHERE (is_active = true);


--
-- Name: idx_nhh_kpi_user_due_date_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nhh_kpi_user_due_date_type ON public.nhh_kpi USING btree (user_id, due_date_type);


--
-- Name: idx_nhh_kpi_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nhh_kpi_user_id ON public.nhh_kpi USING btree (user_id);


--
-- Name: idx_nomenclatures_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nomenclatures_code ON public.nomenclatures USING btree (code);


--
-- Name: idx_nomenclatures_code_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nomenclatures_code_year ON public.nomenclatures USING btree (code, year);


--
-- Name: idx_nomenclatures_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nomenclatures_created_by ON public.nomenclatures USING btree (created_by);


--
-- Name: idx_nomenclatures_db_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nomenclatures_db_id ON public.nomenclatures USING btree (db_id);


--
-- Name: idx_nomenclatures_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nomenclatures_is_deleted ON public.nomenclatures USING btree (is_deleted);


--
-- Name: idx_nomenclatures_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nomenclatures_parent_id ON public.nomenclatures USING btree (parent_id);


--
-- Name: idx_nomenclatures_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_nomenclatures_year ON public.nomenclatures USING btree (year);


--
-- Name: idx_org_db_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_org_db_id ON public.organizations USING btree (db_id);


--
-- Name: idx_permission; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_permission ON public.permissions USING btree (db_id, permission_type, worker_user_id);


--
-- Name: idx_permissions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_permissions ON public.permissions USING btree (db_id, permission_type, control_type, user_id, department_id);


--
-- Name: idx_permissions_worker; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_permissions_worker ON public.permissions USING btree (worker_user_id, permission_type, db_id, control_type, user_id, department_id);


--
-- Name: idx_positions_department_ids_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_positions_department_ids_gin ON public.positions USING gin (department_ids);


--
-- Name: idx_read_logs_main_id_read_by_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_read_logs_main_id_read_by_type ON public.read_logs USING btree (main_id, read_by, type);


--
-- Name: INDEX idx_read_logs_main_id_read_by_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.idx_read_logs_main_id_read_by_type IS 'Optimizes read_at lookup for document sends';


--
-- Name: idx_record_history_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_action ON public.record_history USING btree (action);


--
-- Name: idx_record_history_action_completed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_action_completed ON public.record_history USING btree (created_at DESC) WHERE ((action)::text = 'completed'::text);


--
-- Name: idx_record_history_action_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_action_created ON public.record_history USING btree (created_at DESC) WHERE ((action)::text = 'created'::text);


--
-- Name: idx_record_history_action_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_action_deleted ON public.record_history USING btree (created_at DESC) WHERE ((action)::text = 'deleted'::text);


--
-- Name: idx_record_history_action_submitted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_action_submitted ON public.record_history USING btree (created_at DESC) WHERE ((action)::text = 'submitted'::text);


--
-- Name: idx_record_history_action_updated; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_action_updated ON public.record_history USING btree (created_at DESC) WHERE ((action)::text = 'updated'::text);


--
-- Name: idx_record_history_active_records; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_active_records ON public.record_history USING btree (record_id, created_at DESC) WHERE ((action)::text <> 'deleted'::text);


--
-- Name: idx_record_history_attachments_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_attachments_gin ON public.record_history USING gin (attachments) WHERE (attachments IS NOT NULL);


--
-- Name: idx_record_history_created_at_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_created_at_desc ON public.record_history USING btree (created_at DESC);


--
-- Name: idx_record_history_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_created_by ON public.record_history USING btree (created_by);


--
-- Name: idx_record_history_data_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_data_gin ON public.record_history USING gin (data jsonb_path_ops);


--
-- Name: idx_record_history_metadata_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_metadata_gin ON public.record_history USING gin (metadata jsonb_path_ops) WHERE (metadata IS NOT NULL);


--
-- Name: idx_record_history_org_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_org_created ON public.record_history USING btree (organization_id, created_at DESC);


--
-- Name: idx_record_history_record_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_record_created ON public.record_history USING btree (record_id, created_at DESC);


--
-- Name: idx_record_history_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_record_id ON public.record_history USING btree (record_id);


--
-- Name: idx_record_history_record_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_record_type_id ON public.record_history USING btree (record_type_id);


--
-- Name: idx_record_history_type_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_type_created ON public.record_history USING btree (record_type_id, created_at DESC);


--
-- Name: idx_record_history_user_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_history_user_created ON public.record_history USING btree (created_by, created_at DESC);


--
-- Name: idx_record_types_completed_schema_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_types_completed_schema_gin ON public.record_types USING gin (completed_json_schema jsonb_path_ops);


--
-- Name: idx_record_types_created_at_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_types_created_at_desc ON public.record_types USING btree (created_at DESC);


--
-- Name: idx_record_types_db_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_types_db_id ON public.record_types USING btree (db_id);


--
-- Name: idx_record_types_enabled_editor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_types_enabled_editor ON public.record_types USING btree (editor) WHERE (is_enabled = true);


--
-- Name: idx_record_types_enabled_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_types_enabled_name ON public.record_types USING btree (name) WHERE (is_enabled = true);


--
-- Name: idx_record_types_file_requirement_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_types_file_requirement_gin ON public.record_types USING gin (file_requirement jsonb_path_ops);


--
-- Name: idx_record_types_is_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_types_is_enabled ON public.record_types USING btree (is_enabled);


--
-- Name: idx_record_types_json_schema_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_types_json_schema_gin ON public.record_types USING gin (json_schema jsonb_path_ops);


--
-- Name: idx_record_types_name_fts; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_types_name_fts ON public.record_types USING gin (to_tsvector('english'::regconfig, name));


--
-- Name: idx_record_types_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_types_name_trgm ON public.record_types USING gin (name public.gin_trgm_ops);


--
-- Name: idx_record_types_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_types_organization_id ON public.record_types USING btree (organization_id);


--
-- Name: idx_record_types_settings_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_types_settings_gin ON public.record_types USING gin (settings jsonb_path_ops);


--
-- Name: idx_record_types_tags_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_types_tags_gin ON public.record_types USING gin (tags);


--
-- Name: idx_record_types_tenant_org_enabled_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_types_tenant_org_enabled_created ON public.record_types USING btree (db_id, organization_id, is_enabled, created_at DESC);


--
-- Name: idx_record_types_updated_at_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_record_types_updated_at_desc ON public.record_types USING btree (updated_at DESC);


--
-- Name: idx_records_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_active ON public.records USING btree (id) WHERE (deleted_at IS NULL);


--
-- Name: idx_records_active_by_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_active_by_org ON public.records USING btree (organization_id, created_at DESC) WHERE (deleted_at IS NULL);


--
-- Name: idx_records_active_by_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_active_by_user ON public.records USING btree (user_id, created_at DESC) WHERE (deleted_at IS NULL);


--
-- Name: idx_records_attachments_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_attachments_gin ON public.records USING gin (attachments) WHERE (attachments IS NOT NULL);


--
-- Name: idx_records_completed; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_completed ON public.records USING btree (id) WHERE (completed_at IS NOT NULL);


--
-- Name: idx_records_completed_at_asc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_completed_at_asc ON public.records USING btree (completed_at) WHERE (completed_at IS NOT NULL);


--
-- Name: idx_records_completed_at_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_completed_at_desc ON public.records USING btree (completed_at DESC) WHERE (completed_at IS NOT NULL);


--
-- Name: idx_records_completed_by_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_completed_by_type ON public.records USING btree (record_type_id, completed_at DESC) WHERE ((completed_at IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: idx_records_created_at_asc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_created_at_asc ON public.records USING btree (created_at);


--
-- Name: idx_records_created_at_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_created_at_desc ON public.records USING btree (created_at DESC);


--
-- Name: idx_records_data_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_data_gin ON public.records USING gin (data jsonb_path_ops);


--
-- Name: idx_records_db_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_db_id ON public.records USING btree (db_id);


--
-- Name: idx_records_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_deleted_at ON public.records USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: idx_records_locked_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_locked_at ON public.records USING btree (locked_at) WHERE (locked_at IS NOT NULL);


--
-- Name: idx_records_organization_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_organization_id ON public.records USING btree (organization_id);


--
-- Name: idx_records_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_pending ON public.records USING btree (id) WHERE (completed_at IS NULL);


--
-- Name: idx_records_pending_by_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_pending_by_type ON public.records USING btree (record_type_id, created_at DESC) WHERE ((completed_at IS NULL) AND (deleted_at IS NULL));


--
-- Name: idx_records_pinpp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_pinpp ON public.records USING btree (pinpp);


--
-- Name: idx_records_pinpp_textsearch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_pinpp_textsearch ON public.records USING gin (to_tsvector('english'::regconfig, (pinpp)::text));


--
-- Name: idx_records_pinpp_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_pinpp_trgm ON public.records USING gin (pinpp public.gin_trgm_ops);


--
-- Name: idx_records_record_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_record_type_id ON public.records USING btree (record_type_id);


--
-- Name: idx_records_tenant_org_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_tenant_org_created ON public.records USING btree (db_id, organization_id, created_at DESC);


--
-- Name: idx_records_unlocked; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_unlocked ON public.records USING btree (id) WHERE (locked_at IS NULL);


--
-- Name: idx_records_updated_at_asc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_updated_at_asc ON public.records USING btree (updated_at);


--
-- Name: idx_records_updated_at_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_updated_at_desc ON public.records USING btree (updated_at DESC);


--
-- Name: idx_records_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_user_id ON public.records USING btree (user_id);


--
-- Name: idx_records_user_type_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_records_user_type_created ON public.records USING btree (user_id, record_type_id, created_at DESC);


--
-- Name: idx_reference_types_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reference_types_is_active ON public.reference_types USING btree (is_active);


--
-- Name: idx_reference_types_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reference_types_is_deleted ON public.reference_types USING btree (is_deleted);


--
-- Name: idx_reference_types_sort_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reference_types_sort_order ON public.reference_types USING btree (sort_order);


--
-- Name: idx_reference_types_type_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reference_types_type_code ON public.reference_types USING btree (type_code);


--
-- Name: idx_repeatable_plan_changes_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_plan_changes_created_at ON public.repeatable_plan_changes USING btree (created_at);


--
-- Name: idx_repeatable_plan_changes_db_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_plan_changes_db_id ON public.repeatable_plan_changes USING btree (db_id);


--
-- Name: idx_repeatable_plan_changes_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_plan_changes_plan_id ON public.repeatable_plan_changes USING btree (plan_id);


--
-- Name: idx_repeatable_plan_db_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_plan_db_id ON public.repeatable_plan USING btree (db_id);


--
-- Name: idx_repeatable_plan_document; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_plan_document ON public.repeatable_plan USING btree (document_id, document_year);


--
-- Name: idx_repeatable_plan_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_plan_document_id ON public.repeatable_plan USING btree (document_id);


--
-- Name: idx_repeatable_plan_document_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_plan_document_year ON public.repeatable_plan USING btree (document_year);


--
-- Name: idx_repeatable_plan_first_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_plan_first_task_id ON public.repeatable_plan USING btree (first_task_id);


--
-- Name: idx_repeatable_task_activation_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_task_activation_date ON public.repeatable_task USING btree (activation_date);


--
-- Name: idx_repeatable_task_activation_date_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_task_activation_date_status ON public.repeatable_task USING btree (activation_date, status);


--
-- Name: idx_repeatable_task_active_task_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_task_active_task_id ON public.repeatable_task USING btree (active_task_id);


--
-- Name: idx_repeatable_task_cron_db_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_task_cron_db_id ON public.repeatable_task_cron USING btree (db_id);


--
-- Name: idx_repeatable_task_cron_document_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_task_cron_document_year ON public.repeatable_task_cron USING btree (document_year);


--
-- Name: idx_repeatable_task_cron_run_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_task_cron_run_date ON public.repeatable_task_cron USING btree (run_date);


--
-- Name: idx_repeatable_task_cron_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_task_cron_status ON public.repeatable_task_cron USING btree (status);


--
-- Name: idx_repeatable_task_db_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_task_db_id ON public.repeatable_task USING btree (db_id);


--
-- Name: idx_repeatable_task_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_task_document_id ON public.repeatable_task USING btree (document_id);


--
-- Name: idx_repeatable_task_document_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_task_document_year ON public.repeatable_task USING btree (document_year);


--
-- Name: idx_repeatable_task_due_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_task_due_date ON public.repeatable_task USING btree (due_date);


--
-- Name: idx_repeatable_task_plan_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_task_plan_id ON public.repeatable_task USING btree (plan_id);


--
-- Name: idx_repeatable_task_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_task_status ON public.repeatable_task USING btree (status);


--
-- Name: idx_repeatable_task_year_status_activation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_repeatable_task_year_status_activation ON public.repeatable_task USING btree (document_year, status, activation_date) WHERE (active_task_id IS NULL);


--
-- Name: idx_resolution_template_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_resolution_template_type ON public.resolution_template USING btree (type);


--
-- Name: idx_sp_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sp_category ON public.staffing_positions USING btree (category_id);


--
-- Name: idx_sp_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sp_category_id ON public.staffing_positions USING btree (category_id) WHERE (is_deleted = false);


--
-- Name: idx_sp_db; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sp_db ON public.staffing_positions USING btree (db_id) WHERE (is_deleted = false);


--
-- Name: idx_sp_db_level; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sp_db_level ON public.staffing_positions USING btree (db_id) WHERE ((unit_id IS NULL) AND (is_deleted = false));


--
-- Name: idx_sp_db_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sp_db_status ON public.staffing_positions USING btree (db_id, status) WHERE (is_deleted = false);


--
-- Name: idx_sp_order_number_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sp_order_number_trgm ON public.staffing_positions USING gin (order_number public.gin_trgm_ops) WHERE (is_deleted = false);


--
-- Name: idx_sp_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sp_position ON public.staffing_positions USING btree (position_id) WHERE (is_deleted = false);


--
-- Name: idx_sp_sequence_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sp_sequence_index ON public.staffing_positions USING btree (sequence_index) WHERE (is_deleted = false);


--
-- Name: idx_sp_unit; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sp_unit ON public.staffing_positions USING btree (unit_id) WHERE (is_deleted = false);


--
-- Name: idx_static_files_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_static_files_code ON public.static_files USING btree (code);


--
-- Name: idx_static_files_file_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_static_files_file_id ON public.static_files USING btree (file_id);


--
-- Name: idx_su_db; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_su_db ON public.structural_units USING btree (db_id) WHERE (is_deleted = false);


--
-- Name: idx_su_db_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_su_db_type ON public.structural_units USING btree (db_id, unit_type_id) WHERE (is_deleted = false);


--
-- Name: idx_su_hierarchy; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_su_hierarchy ON public.structural_units USING gist (parent_hierarchy) WHERE (is_deleted = false);


--
-- Name: idx_su_parent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_su_parent ON public.structural_units USING btree (parent_id) WHERE (is_deleted = false);


--
-- Name: idx_su_parent_order; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_su_parent_order ON public.structural_units USING btree (parent_id, order_index) WHERE (is_deleted = false);


--
-- Name: idx_suggestions_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_suggestions_category ON public.suggestions USING btree (category) WHERE (is_deleted IS NOT TRUE);


--
-- Name: idx_suggestions_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_suggestions_created_by ON public.suggestions USING btree (created_by) WHERE (is_deleted IS NOT TRUE);


--
-- Name: idx_suggestions_db_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_suggestions_db_id ON public.suggestions USING btree (db_id) WHERE (is_deleted IS NOT TRUE);


--
-- Name: idx_suggestions_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_suggestions_status ON public.suggestions USING btree (status) WHERE (is_deleted IS NOT TRUE);


--
-- Name: idx_task_rec_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_task_rec_id ON public.task_recipients USING btree (id) WHERE (is_deleted = false);


--
-- Name: idx_task_rec_parent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_task_rec_parent ON public.task_recipients USING btree (parent_id) WHERE (is_deleted = false);


--
-- Name: idx_task_rec_parent_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_task_rec_parent_deleted ON public.task_recipients USING btree (parent_id, is_deleted) WHERE (is_deleted = false);


--
-- Name: idx_terms_fixed_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_terms_fixed_is_deleted ON public.terms_fixed USING btree (is_deleted);


--
-- Name: idx_terms_fixed_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_terms_fixed_type ON public.terms_fixed USING btree (type);


--
-- Name: idx_terms_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_terms_is_deleted ON public.terms USING btree (is_deleted);


--
-- Name: idx_terms_reference_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_terms_reference_type_id ON public.terms USING btree (reference_type_id);


--
-- Name: idx_vacations_approval_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vacations_approval_status ON public.vacations USING btree (approval_status);


--
-- Name: idx_vacations_approval_step; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vacations_approval_step ON public.vacations USING btree (approval_step);


--
-- Name: idx_vacations_department_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vacations_department_id ON public.vacations USING btree (department_id);


--
-- Name: idx_vacations_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vacations_document_id ON public.vacations USING btree (document_id);


--
-- Name: idx_vacations_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vacations_is_deleted ON public.vacations USING btree (is_deleted);


--
-- Name: idx_vacations_leave_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vacations_leave_type ON public.vacations USING btree (leave_type);


--
-- Name: idx_vacations_position_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vacations_position_id ON public.vacations USING btree (position_id);


--
-- Name: idx_vacations_schedule_year; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vacations_schedule_year ON public.vacations USING btree (schedule_year);


--
-- Name: idx_vacations_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vacations_status ON public.vacations USING btree (status);


--
-- Name: idx_vacations_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vacations_user_id ON public.vacations USING btree (user_id);


--
-- Name: idx_vacations_work_year_from; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vacations_work_year_from ON public.vacations USING btree (work_year_from);


--
-- Name: idx_vacations_work_year_to; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vacations_work_year_to ON public.vacations USING btree (work_year_to);


--
-- Name: idx_watermark_logs_document_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_watermark_logs_document_id ON public.watermark_logs USING btree (document_id);


--
-- Name: idx_watermark_logs_file_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_watermark_logs_file_user ON public.watermark_logs USING btree (file_id, user_id);


--
-- Name: idx_watermark_logs_ip_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_watermark_logs_ip_address ON public.watermark_logs USING btree (ip_address);


--
-- Name: idx_watermark_logs_user_document; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_watermark_logs_user_document ON public.watermark_logs USING btree (user_id, document_id);


--
-- Name: idx_watermark_logs_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_watermark_logs_user_id ON public.watermark_logs USING btree (user_id);


--
-- Name: idx_watermark_logs_view_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_watermark_logs_view_timestamp ON public.watermark_logs USING btree (view_timestamp DESC);


--
-- Name: idx_watermark_logs_watermark_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_watermark_logs_watermark_code ON public.watermark_logs USING btree (watermark_code);


--
-- Name: internal_documents_document_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX internal_documents_document_id_index ON public.internal_documents USING btree (document_id);


--
-- Name: migration_progress_migration_type_oracle_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX migration_progress_migration_type_oracle_id_index ON public.migration_progress USING btree (migration_type, oracle_id);


--
-- Name: migration_progress_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX migration_progress_status_index ON public.migration_progress USING btree (status);


--
-- Name: news_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX news_type_index ON public.news USING btree (type);


--
-- Name: notifications_recipient_user_id_is_deleted_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifications_recipient_user_id_is_deleted_index ON public.notifications USING btree (recipient_user_id, is_deleted);


--
-- Name: notifications_recipient_user_id_is_deleted_is_read_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX notifications_recipient_user_id_is_deleted_is_read_index ON public.notifications USING btree (recipient_user_id, is_deleted, is_read);


--
-- Name: organization_users_full_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX organization_users_full_name_idx ON public.organization_users USING btree (full_name);


--
-- Name: organization_users_org_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX organization_users_org_id_idx ON public.organization_users USING btree (org_id);


--
-- Name: permissions_db_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX permissions_db_id_index ON public.permissions USING btree (db_id);


--
-- Name: permissions_db_id_permission_type_worker_user_id_control_type_i; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX permissions_db_id_permission_type_worker_user_id_control_type_i ON public.permissions USING btree (db_id, permission_type, worker_user_id, control_type);


--
-- Name: permissions_department_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX permissions_department_id_index ON public.permissions USING btree (department_id);


--
-- Name: permissions_permission_type_db_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX permissions_permission_type_db_id_index ON public.permissions USING btree (permission_type, db_id DESC);


--
-- Name: permissions_permission_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX permissions_permission_type_index ON public.permissions USING btree (permission_type DESC);


--
-- Name: permissions_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX permissions_user_id_index ON public.permissions USING btree (user_id);


--
-- Name: permissions_worker_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX permissions_worker_user_id_index ON public.permissions USING btree (worker_user_id);


--
-- Name: pkcs10_until_confirm_code_uindex; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX pkcs10_until_confirm_code_uindex ON public.pkcs10_until_confirm USING btree (code);


--
-- Name: pkcs10_until_confirm_id_uindex; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX pkcs10_until_confirm_id_uindex ON public.pkcs10_until_confirm USING btree (id);


--
-- Name: pkcs10_until_confirm_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX pkcs10_until_confirm_pk ON public.pkcs10_until_confirm USING btree (id);


--
-- Name: pkcs10_until_confirm_subj_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pkcs10_until_confirm_subj_user_id_index ON public.pkcs10_until_confirm USING btree (subj_user_id);


--
-- Name: static_data_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX static_data_code_index ON public.static_data USING btree (code);


--
-- Name: sync_items_entity_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sync_items_entity_id_index ON public.sync_items USING btree (entity_id);


--
-- Name: sync_items_entity_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sync_items_entity_type_index ON public.sync_items USING btree (entity_type);


--
-- Name: sync_items_package_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sync_items_package_id_index ON public.sync_items USING btree (package_id);


--
-- Name: sync_packages_direction_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sync_packages_direction_index ON public.sync_packages USING btree (direction);


--
-- Name: sync_packages_direction_index_2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sync_packages_direction_index_2 ON public.sync_packages USING btree (direction);


--
-- Name: sync_packages_direction_last_updated_time_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sync_packages_direction_last_updated_time_index ON public.sync_packages USING btree (direction, last_updated_time);


--
-- Name: sync_packages_file_hash_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sync_packages_file_hash_index ON public.sync_packages USING btree (file_hash) WHERE ((direction = 2) AND (status = 3));


--
-- Name: sync_packages_status_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sync_packages_status_index ON public.sync_packages USING btree (status);


--
-- Name: task_draft_document_send_uindex; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX task_draft_document_send_uindex ON public.task_draft_until_sign USING btree (document_send_id) WHERE (is_deleted IS FALSE);


--
-- Name: uq_document_permissions_document_user_partial; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_document_permissions_document_user_partial ON public.document_permissions USING btree (document_id, user_id) WHERE (is_deleted = false);


--
-- Name: users_personal_code_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_personal_code_index ON public.users USING btree (personal_code);


--
-- Name: workflow_ai_suggestions_document_id_inx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX workflow_ai_suggestions_document_id_inx ON public.ai_suggestions USING btree (document_id);


--
-- Name: generate_certificate_hash_uindex; Type: INDEX; Schema: uzcrypto; Owner: -
--

CREATE UNIQUE INDEX generate_certificate_hash_uindex ON uzcrypto.generate_certificate USING btree (hash);


--
-- Name: generate_certificate_pinpp_index; Type: INDEX; Schema: uzcrypto; Owner: -
--

CREATE INDEX generate_certificate_pinpp_index ON uzcrypto.generate_certificate USING btree (pinpp);


--
-- Name: generate_certificate_register_request_id_uindex; Type: INDEX; Schema: uzcrypto; Owner: -
--

CREATE UNIQUE INDEX generate_certificate_register_request_id_uindex ON uzcrypto.generate_certificate USING btree (register_request_id);


--
-- Name: generate_certificate_serial_uindex; Type: INDEX; Schema: uzcrypto; Owner: -
--

CREATE UNIQUE INDEX generate_certificate_serial_uindex ON uzcrypto.generate_certificate USING btree (serial);


--
-- Name: document_internal_order_state document_year_generate_trigger; Type: TRIGGER; Schema: president_assignments; Owner: -
--

CREATE TRIGGER document_year_generate_trigger BEFORE INSERT ON president_assignments.document_internal_order_state FOR EACH ROW EXECUTE FUNCTION president_assignments.set_document_year_by_document_id();


--
-- Name: documents document_year_generate_trigger; Type: TRIGGER; Schema: president_assignments; Owner: -
--

CREATE TRIGGER document_year_generate_trigger BEFORE INSERT ON president_assignments.documents FOR EACH ROW EXECUTE FUNCTION president_assignments.set_year_by_id();


--
-- Name: task_recipients document_year_generate_trigger; Type: TRIGGER; Schema: president_assignments; Owner: -
--

CREATE TRIGGER document_year_generate_trigger BEFORE INSERT ON president_assignments.task_recipients FOR EACH ROW EXECUTE FUNCTION president_assignments.set_document_year_by_document_id();


--
-- Name: task_requests document_year_generate_trigger; Type: TRIGGER; Schema: president_assignments; Owner: -
--

CREATE TRIGGER document_year_generate_trigger BEFORE INSERT ON president_assignments.task_requests FOR EACH ROW EXECUTE FUNCTION president_assignments.set_document_year_by_document_id();


--
-- Name: task_send document_year_generate_trigger; Type: TRIGGER; Schema: president_assignments; Owner: -
--

CREATE TRIGGER document_year_generate_trigger BEFORE INSERT ON president_assignments.task_send FOR EACH ROW EXECUTE FUNCTION president_assignments.set_document_year_by_document_id();


--
-- Name: tasks document_year_generate_trigger; Type: TRIGGER; Schema: president_assignments; Owner: -
--

CREATE TRIGGER document_year_generate_trigger BEFORE INSERT ON president_assignments.tasks FOR EACH ROW EXECUTE FUNCTION president_assignments.set_document_year_by_document_id();


--
-- Name: document_internal_order_state row_update__president_assignments__doc_internal_order_state; Type: TRIGGER; Schema: president_assignments; Owner: -
--

CREATE TRIGGER row_update__president_assignments__doc_internal_order_state AFTER INSERT OR UPDATE ON president_assignments.document_internal_order_state FOR EACH ROW EXECUTE FUNCTION president_assignments.row_updated();


--
-- Name: documents row_update__president_assignments__documents; Type: TRIGGER; Schema: president_assignments; Owner: -
--

CREATE TRIGGER row_update__president_assignments__documents BEFORE INSERT OR UPDATE ON president_assignments.documents FOR EACH ROW EXECUTE FUNCTION president_assignments.row_updated();


--
-- Name: task_recipients row_update__president_assignments__task_recipients; Type: TRIGGER; Schema: president_assignments; Owner: -
--

CREATE TRIGGER row_update__president_assignments__task_recipients BEFORE INSERT OR UPDATE ON president_assignments.task_recipients FOR EACH ROW EXECUTE FUNCTION president_assignments.row_updated();


--
-- Name: task_requests row_update__president_assignments__task_requests; Type: TRIGGER; Schema: president_assignments; Owner: -
--

CREATE TRIGGER row_update__president_assignments__task_requests BEFORE INSERT OR UPDATE ON president_assignments.task_requests FOR EACH ROW EXECUTE FUNCTION president_assignments.row_updated();


--
-- Name: task_send row_update__president_assignments__task_send; Type: TRIGGER; Schema: president_assignments; Owner: -
--

CREATE TRIGGER row_update__president_assignments__task_send BEFORE INSERT OR UPDATE ON president_assignments.task_send FOR EACH ROW EXECUTE FUNCTION president_assignments.row_updated();


--
-- Name: tasks row_update__president_assignments__tasks; Type: TRIGGER; Schema: president_assignments; Owner: -
--

CREATE TRIGGER row_update__president_assignments__tasks BEFORE INSERT OR UPDATE ON president_assignments.tasks FOR EACH ROW EXECUTE FUNCTION president_assignments.row_updated();


--
-- Name: direction row_update_users; Type: TRIGGER; Schema: president_assignments; Owner: -
--

CREATE TRIGGER row_update_users AFTER INSERT OR UPDATE ON president_assignments.direction FOR EACH ROW EXECUTE FUNCTION president_assignments.row_updated();


--
-- Name: task_send trig_inactive_send_task; Type: TRIGGER; Schema: president_assignments; Owner: -
--

CREATE TRIGGER trig_inactive_send_task BEFORE INSERT ON president_assignments.task_send FOR EACH ROW EXECUTE FUNCTION president_assignments.send_task_set_inactive();


--
-- Name: users after_user_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER after_user_insert AFTER INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.user_after_insert_trigger_func();


--
-- Name: document_send row_update_document_send; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER row_update_document_send BEFORE INSERT OR UPDATE ON public.document_send FOR EACH ROW EXECUTE FUNCTION public.updated_time();


--
-- Name: document_send_signature row_update_document_send_signature; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER row_update_document_send_signature BEFORE INSERT OR UPDATE ON public.document_send_signature FOR EACH ROW EXECUTE FUNCTION public.updated_time();


--
-- Name: documents row_update_documents; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER row_update_documents BEFORE INSERT OR UPDATE ON public.documents FOR EACH ROW EXECUTE FUNCTION public.updated_time();


--
-- Name: users row_update_users; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER row_update_users AFTER INSERT OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION president_assignments.row_updated();


--
-- Name: doc_outgoing_resend set_updated_time_to_documents; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_time_to_documents BEFORE UPDATE ON public.doc_outgoing_resend FOR EACH ROW EXECUTE FUNCTION public.update_updated_time();


--
-- Name: document_outgoing set_updated_time_to_documents; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_time_to_documents BEFORE UPDATE ON public.document_outgoing FOR EACH ROW EXECUTE FUNCTION public.update_updated_time();


--
-- Name: documents set_updated_time_to_documents; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_time_to_documents BEFORE UPDATE ON public.documents FOR EACH ROW EXECUTE FUNCTION public.update_updated_time();


--
-- Name: assignments trg_asgn_sync_status; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_asgn_sync_status AFTER INSERT OR DELETE OR UPDATE ON public.assignments FOR EACH ROW EXECUTE FUNCTION public.fn_sync_sp_status();


--
-- Name: document_signers trg_set_document_signer_type; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_set_document_signer_type BEFORE INSERT OR UPDATE ON public.document_signers FOR EACH ROW EXECUTE FUNCTION public.set_document_signer_type();


--
-- Name: document_signers_staged trg_set_document_signer_type; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_set_document_signer_type BEFORE INSERT OR UPDATE ON public.document_signers_staged FOR EACH ROW EXECUTE FUNCTION public.set_document_signer_type();


--
-- Name: document_send trg_set_signer_type_to_document_send; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_set_signer_type_to_document_send BEFORE INSERT OR UPDATE ON public.document_send FOR EACH ROW EXECUTE FUNCTION public.set_signer_type_to_document_send();


--
-- Name: document_send_staged trg_set_signer_type_to_document_send; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_set_signer_type_to_document_send BEFORE INSERT OR UPDATE ON public.document_send_staged FOR EACH ROW EXECUTE FUNCTION public.set_signer_type_to_document_send();


--
-- Name: staffing_positions trg_sp_updated; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_sp_updated BEFORE UPDATE ON public.staffing_positions FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: structural_units trg_su_path; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_su_path BEFORE INSERT OR UPDATE OF parent_id ON public.structural_units FOR EACH ROW EXECUTE FUNCTION public.fn_su_set_path();


--
-- Name: structural_units trg_su_updated; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_su_updated BEFORE UPDATE ON public.structural_units FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: recipient_answer_actions trig_inactive_send_task; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trig_inactive_send_task BEFORE INSERT ON public.recipient_answer_actions FOR EACH ROW EXECUTE FUNCTION public.send_task_set_inactive();


--
-- Name: documents trig_set_delete_doc; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trig_set_delete_doc AFTER UPDATE OF is_deleted ON public.documents FOR EACH ROW EXECUTE FUNCTION public.update_document_is_deleted();


--
-- Name: record_types trigger_record_types_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_record_types_updated_at BEFORE UPDATE ON public.record_types FOR EACH ROW EXECUTE FUNCTION public.update_record_types_updated_at();


--
-- Name: users trigger_set_user_personal_code; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_set_user_personal_code BEFORE INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_user_personal_code();


--
-- Name: document_agreement trigger_to_inactive_agreements; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_to_inactive_agreements AFTER INSERT ON public.document_agreement FOR EACH ROW EXECUTE FUNCTION public.to_inactive_agreements();


--
-- Name: integrations trigger_update_integrations_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_integrations_updated_at BEFORE UPDATE ON public.integrations FOR EACH ROW EXECUTE FUNCTION public.update_integrations_updated_at();


--
-- Name: static_files trigger_update_static_files_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_static_files_updated_at BEFORE UPDATE ON public.static_files FOR EACH ROW EXECUTE FUNCTION public.update_static_files_updated_at();


--
-- Name: users trigger_update_user_parent_department_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_user_parent_department_id BEFORE INSERT OR UPDATE OF department_id ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_user_parent_department_id();


--
-- Name: background_checks update_background_checks_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_background_checks_updated_at BEFORE UPDATE ON public.background_checks FOR EACH ROW EXECUTE FUNCTION public.update_background_checks_updated_at();


--
-- Name: event_handlers update_event_handlers_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_event_handlers_updated_at BEFORE UPDATE ON public.event_handlers FOR EACH ROW EXECUTE FUNCTION public.update_event_handlers_updated_at();


--
-- Name: event_pool update_event_pool_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_event_pool_updated_at BEFORE UPDATE ON public.event_pool FOR EACH ROW EXECUTE FUNCTION public.update_event_pool_updated_at();


--
-- Name: internal_notifications update_internal_notifications_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_internal_notifications_updated_at BEFORE UPDATE ON public.internal_notifications FOR EACH ROW EXECUTE FUNCTION public.update_internal_notifications_updated_at();


--
-- Name: records update_records_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_records_updated_at BEFORE UPDATE ON public.records FOR EACH ROW EXECUTE FUNCTION public.update_records_updated_at();


--
-- Name: event_pool validate_event_pool_log_trigger; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER validate_event_pool_log_trigger BEFORE INSERT OR UPDATE ON public.event_pool FOR EACH ROW EXECUTE FUNCTION public.validate_event_pool_log();


--
-- Name: document_internal_order_state document_internal_order_documents_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.document_internal_order_state
    ADD CONSTRAINT document_internal_order_documents_id_fk FOREIGN KEY (document_id) REFERENCES president_assignments.documents(id);


--
-- Name: document_internal_order_state document_internal_order_organizations_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.document_internal_order_state
    ADD CONSTRAINT document_internal_order_organizations_id_fk FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: document_internal_order_state document_internal_order_users_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.document_internal_order_state
    ADD CONSTRAINT document_internal_order_users_id_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: documents documents_direction_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.documents
    ADD CONSTRAINT documents_direction_id_fk FOREIGN KEY (direction_id) REFERENCES president_assignments.direction(id);


--
-- Name: documents documents_document_types_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.documents
    ADD CONSTRAINT documents_document_types_id_fk FOREIGN KEY (type_id) REFERENCES public.document_types(id);


--
-- Name: documents documents_documents_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.documents
    ADD CONSTRAINT documents_documents_id_fk FOREIGN KEY (document_id) REFERENCES president_assignments.documents(id);


--
-- Name: documents documents_organizations_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.documents
    ADD CONSTRAINT documents_organizations_id_fk FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: documents documents_users_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.documents
    ADD CONSTRAINT documents_users_id_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: documents documents_users_id_fk_2; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.documents
    ADD CONSTRAINT documents_users_id_fk_2 FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: task_recipients task_recipients_created_by_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_recipients
    ADD CONSTRAINT task_recipients_created_by_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: task_recipients task_recipients_db_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_recipients
    ADD CONSTRAINT task_recipients_db_id_fk FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: task_recipients task_recipients_documents_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_recipients
    ADD CONSTRAINT task_recipients_documents_id_fk FOREIGN KEY (document_id) REFERENCES president_assignments.documents(id);


--
-- Name: task_recipients task_recipients_done_by_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_recipients
    ADD CONSTRAINT task_recipients_done_by_fk FOREIGN KEY (done_by) REFERENCES public.users(id);


--
-- Name: task_recipients task_recipients_recipient_db_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_recipients
    ADD CONSTRAINT task_recipients_recipient_db_id_fk FOREIGN KEY (recipient_db_id) REFERENCES public.organizations(id);


--
-- Name: task_recipients task_recipients_recipient_user_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_recipients
    ADD CONSTRAINT task_recipients_recipient_user_id_fk FOREIGN KEY (recipient_user_id) REFERENCES public.users(id);


--
-- Name: task_recipients task_recipients_tasks_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_recipients
    ADD CONSTRAINT task_recipients_tasks_id_fk FOREIGN KEY (task_id) REFERENCES president_assignments.tasks(id);


--
-- Name: task_recipients task_recipients_users_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_recipients
    ADD CONSTRAINT task_recipients_users_id_fk FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: task_requests task_requests_created_by_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_requests
    ADD CONSTRAINT task_requests_created_by_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: task_requests task_requests_db_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_requests
    ADD CONSTRAINT task_requests_db_id_fk FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: task_requests task_requests_documents_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_requests
    ADD CONSTRAINT task_requests_documents_id_fk FOREIGN KEY (document_id) REFERENCES president_assignments.documents(id);


--
-- Name: task_requests task_requests_recipient_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_requests
    ADD CONSTRAINT task_requests_recipient_id_fk FOREIGN KEY (recipient_id) REFERENCES president_assignments.task_recipients(id);


--
-- Name: task_requests task_requests_tasks_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_requests
    ADD CONSTRAINT task_requests_tasks_id_fk FOREIGN KEY (task_id) REFERENCES president_assignments.tasks(id);


--
-- Name: task_send task_send_documents_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_send
    ADD CONSTRAINT task_send_documents_id_fk FOREIGN KEY (document_id) REFERENCES president_assignments.documents(id);


--
-- Name: task_send task_send_organizations_recipient_db_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_send
    ADD CONSTRAINT task_send_organizations_recipient_db_id_fk FOREIGN KEY (recipient_db_id) REFERENCES public.organizations(id);


--
-- Name: task_send task_send_organizations_sender_db_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_send
    ADD CONSTRAINT task_send_organizations_sender_db_id_fk FOREIGN KEY (sender_db_id) REFERENCES public.organizations(id);


--
-- Name: task_send task_send_recipient_user_id_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_send
    ADD CONSTRAINT task_send_recipient_user_id_id_fk FOREIGN KEY (recipient_user_id) REFERENCES public.users(id);


--
-- Name: task_send task_send_sender_users_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_send
    ADD CONSTRAINT task_send_sender_users_id_fk FOREIGN KEY (sender_user_id) REFERENCES public.users(id);


--
-- Name: task_send task_send_task_recipients_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_send
    ADD CONSTRAINT task_send_task_recipients_id_fk FOREIGN KEY (recipient_id) REFERENCES president_assignments.task_recipients(id);


--
-- Name: task_send task_send_task_requests_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_send
    ADD CONSTRAINT task_send_task_requests_id_fk FOREIGN KEY (request_id) REFERENCES president_assignments.task_requests(id);


--
-- Name: task_send task_send_tasks_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_send
    ADD CONSTRAINT task_send_tasks_id_fk FOREIGN KEY (task_id) REFERENCES president_assignments.tasks(id);


--
-- Name: task_send task_send_users_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.task_send
    ADD CONSTRAINT task_send_users_id_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: tasks tasks_documents_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.tasks
    ADD CONSTRAINT tasks_documents_id_fk FOREIGN KEY (document_id) REFERENCES president_assignments.documents(id);


--
-- Name: tasks tasks_organizations_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.tasks
    ADD CONSTRAINT tasks_organizations_id_fk FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: tasks tasks_users_id_fk; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.tasks
    ADD CONSTRAINT tasks_users_id_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: tasks tasks_users_id_fk_2; Type: FK CONSTRAINT; Schema: president_assignments; Owner: -
--

ALTER TABLE ONLY president_assignments.tasks
    ADD CONSTRAINT tasks_users_id_fk_2 FOREIGN KEY (done_by) REFERENCES public.users(id);


--
-- Name: access_tokens access_tokens_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_tokens
    ADD CONSTRAINT access_tokens_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: access_tokens access_tokens_root_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.access_tokens
    ADD CONSTRAINT access_tokens_root_id_foreign FOREIGN KEY (root_id) REFERENCES public.access_tokens(id);


--
-- Name: adm_leaders adm_leaders_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adm_leaders
    ADD CONSTRAINT adm_leaders_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: agreement_group agreement_group_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agreement_group
    ADD CONSTRAINT agreement_group_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: agreement_group agreement_group_created_staff_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agreement_group
    ADD CONSTRAINT agreement_group_created_staff_id_foreign FOREIGN KEY (created_staff_id) REFERENCES public.users(id);


--
-- Name: agreement_group agreement_group_deleted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agreement_group
    ADD CONSTRAINT agreement_group_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: agreement_group_member agreement_group_member_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agreement_group_member
    ADD CONSTRAINT agreement_group_member_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: agreement_group_member agreement_group_member_created_staff_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agreement_group_member
    ADD CONSTRAINT agreement_group_member_created_staff_id_foreign FOREIGN KEY (created_staff_id) REFERENCES public.users(id);


--
-- Name: agreement_group_member agreement_group_member_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agreement_group_member
    ADD CONSTRAINT agreement_group_member_group_id_foreign FOREIGN KEY (group_id) REFERENCES public.agreement_group(id);


--
-- Name: agreement_group_member agreement_group_member_staff_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agreement_group_member
    ADD CONSTRAINT agreement_group_member_staff_user_id_foreign FOREIGN KEY (staff_user_id) REFERENCES public.users(id);


--
-- Name: agreement_group agreement_group_updated_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agreement_group
    ADD CONSTRAINT agreement_group_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: assignments assignments_end_order_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_end_order_document_id_fkey FOREIGN KEY (end_order_document_id) REFERENCES public.documents(id);


--
-- Name: assignments assignments_order_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_order_document_id_fkey FOREIGN KEY (start_order_document_id) REFERENCES public.documents(id);


--
-- Name: assignments assignments_staffing_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_staffing_position_id_fkey FOREIGN KEY (staffing_position_id) REFERENCES public.staffing_positions(id) ON DELETE CASCADE;


--
-- Name: assignments assignments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: async_processor async_processor_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.async_processor
    ADD CONSTRAINT async_processor_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: background_check_batches background_check_batches_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_check_batches
    ADD CONSTRAINT background_check_batches_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: background_check_batches background_check_batches_sync_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_check_batches
    ADD CONSTRAINT background_check_batches_sync_package_id_fkey FOREIGN KEY (sync_package_id) REFERENCES public.sync_packages(id) ON DELETE SET NULL;


--
-- Name: background_checks background_checks_batch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_checks
    ADD CONSTRAINT background_checks_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.background_check_batches(id) ON DELETE SET NULL;


--
-- Name: background_checks background_checks_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.background_checks
    ADD CONSTRAINT background_checks_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: building_blocks building_blocks_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.building_blocks
    ADD CONSTRAINT building_blocks_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: static_permissions chancellery_permission_departments_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_permissions
    ADD CONSTRAINT chancellery_permission_departments_id_fk FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: static_permissions chancellery_permission_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_permissions
    ADD CONSTRAINT chancellery_permission_organizations_id_fk FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: static_permissions chancellery_permission_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_permissions
    ADD CONSTRAINT chancellery_permission_users_id_fk FOREIGN KEY (worker_user_id) REFERENCES public.users(id);


--
-- Name: static_permissions chancellery_permission_users_id_fk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_permissions
    ADD CONSTRAINT chancellery_permission_users_id_fk_2 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: content_template content_template_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_template
    ADD CONSTRAINT content_template_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: content_template content_template_deleted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.content_template
    ADD CONSTRAINT content_template_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: corrector corrector_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.corrector
    ADD CONSTRAINT corrector_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: corrector corrector_director_staff_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.corrector
    ADD CONSTRAINT corrector_director_staff_id_foreign FOREIGN KEY (director_staff_id) REFERENCES public.users(id);


--
-- Name: corrector corrector_staff_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.corrector
    ADD CONSTRAINT corrector_staff_id_foreign FOREIGN KEY (staff_id) REFERENCES public.users(id);


--
-- Name: country country_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: delivery_type_changes delivery_type_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_type_changes
    ADD CONSTRAINT delivery_type_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: delivery_type_changes delivery_type_changes_main_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_type_changes
    ADD CONSTRAINT delivery_type_changes_main_id_foreign FOREIGN KEY (main_id) REFERENCES public.delivery_type(id) ON DELETE SET NULL;


--
-- Name: delivery_type delivery_type_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delivery_type
    ADD CONSTRAINT delivery_type_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: department_structure department_structure_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_structure
    ADD CONSTRAINT department_structure_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: department_structure department_structure_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_structure
    ADD CONSTRAINT department_structure_department_id_foreign FOREIGN KEY (department_id) REFERENCES public.departments(id) ON DELETE SET NULL;


--
-- Name: department_structure department_structure_position_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_structure
    ADD CONSTRAINT department_structure_position_id_foreign FOREIGN KEY (position_id) REFERENCES public.positions(id) ON DELETE SET NULL;


--
-- Name: department_structure department_structure_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_structure
    ADD CONSTRAINT department_structure_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: departments departments_chief_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departments
    ADD CONSTRAINT departments_chief_user_id_foreign FOREIGN KEY (chief_user_id) REFERENCES public.users(id);


--
-- Name: doc_outgoing_resend doc_outgoing_send_document_outgoing_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doc_outgoing_resend
    ADD CONSTRAINT doc_outgoing_send_document_outgoing_id_fk FOREIGN KEY (document_outgoing_id) REFERENCES public.document_outgoing(id);


--
-- Name: doc_outgoing_resend doc_outgoing_send_documents_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doc_outgoing_resend
    ADD CONSTRAINT doc_outgoing_send_documents_id_fk FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: doc_outgoing_resend doc_outgoing_send_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doc_outgoing_resend
    ADD CONSTRAINT doc_outgoing_send_organizations_id_fk FOREIGN KEY (sender_db_id) REFERENCES public.organizations(id);


--
-- Name: doc_outgoing_resend doc_outgoing_send_organizations_id_fk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doc_outgoing_resend
    ADD CONSTRAINT doc_outgoing_send_organizations_id_fk_2 FOREIGN KEY (recipient_db_id) REFERENCES public.organizations(id);


--
-- Name: doc_outgoing_resend doc_outgoing_send_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doc_outgoing_resend
    ADD CONSTRAINT doc_outgoing_send_users_id_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: doc_outgoing_resend doc_outgoing_send_users_id_fk_2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doc_outgoing_resend
    ADD CONSTRAINT doc_outgoing_send_users_id_fk_2 FOREIGN KEY (sender_user_id) REFERENCES public.users(id);


--
-- Name: doc_outgoing_resend doc_outgoing_send_users_id_fk_3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.doc_outgoing_resend
    ADD CONSTRAINT doc_outgoing_send_users_id_fk_3 FOREIGN KEY (recipient_user_id) REFERENCES public.users(id);


--
-- Name: document_actions document_actions_action_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_actions
    ADD CONSTRAINT document_actions_action_by_fkey FOREIGN KEY (action_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: document_actions document_actions_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_actions
    ADD CONSTRAINT document_actions_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id) ON DELETE CASCADE;


--
-- Name: document_aggreement_with_organization_changes document_aggreement_with_organization_changes_created_by_foreig; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_aggreement_with_organization_changes
    ADD CONSTRAINT document_aggreement_with_organization_changes_created_by_foreig FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_aggreement_with_organizations document_aggreement_with_organizations_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_aggreement_with_organizations
    ADD CONSTRAINT document_aggreement_with_organizations_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_aggreement_with_organizations document_aggreement_with_organizations_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_aggreement_with_organizations
    ADD CONSTRAINT document_aggreement_with_organizations_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: document_aggreement_with_organizations document_aggreement_with_organizations_employee_doc_signer_id_f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_aggreement_with_organizations
    ADD CONSTRAINT document_aggreement_with_organizations_employee_doc_signer_id_f FOREIGN KEY (employee_doc_signer_id) REFERENCES public.document_signers(id);


--
-- Name: document_aggreement_with_organizations document_aggreement_with_organizations_recipient_db_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_aggreement_with_organizations
    ADD CONSTRAINT document_aggreement_with_organizations_recipient_db_id_foreign FOREIGN KEY (recipient_db_id) REFERENCES public.organizations(id);


--
-- Name: document_aggreement_with_organizations document_aggreement_with_organizations_recipient_doc_signer_id_; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_aggreement_with_organizations
    ADD CONSTRAINT document_aggreement_with_organizations_recipient_doc_signer_id_ FOREIGN KEY (recipient_doc_signer_id) REFERENCES public.document_signers(id);


--
-- Name: document_agreement_changes document_agreement_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_agreement_changes
    ADD CONSTRAINT document_agreement_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_agreement document_agreement_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_agreement
    ADD CONSTRAINT document_agreement_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_agreement document_agreement_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_agreement
    ADD CONSTRAINT document_agreement_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: document_agreement document_agreement_recipient_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_agreement
    ADD CONSTRAINT document_agreement_recipient_user_id_foreign FOREIGN KEY (recipient_user_id) REFERENCES public.users(id);


--
-- Name: document_business_trip_changes document_business_trip_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_business_trip_changes
    ADD CONSTRAINT document_business_trip_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_business_trip document_business_trip_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_business_trip
    ADD CONSTRAINT document_business_trip_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_business_trip document_business_trip_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_business_trip
    ADD CONSTRAINT document_business_trip_department_id_foreign FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: document_business_trip document_business_trip_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_business_trip
    ADD CONSTRAINT document_business_trip_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: document_business_trip document_business_trip_employee_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_business_trip
    ADD CONSTRAINT document_business_trip_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES public.users(id);


--
-- Name: document_changes document_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_changes
    ADD CONSTRAINT document_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_files_version document_files_version_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_files_version
    ADD CONSTRAINT document_files_version_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_files_version document_files_version_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_files_version
    ADD CONSTRAINT document_files_version_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: document_files_version document_files_version_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_files_version
    ADD CONSTRAINT document_files_version_file_id_foreign FOREIGN KEY (file_id) REFERENCES public.files(id);


--
-- Name: document_flow document_flow_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_flow
    ADD CONSTRAINT document_flow_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_flow document_flow_deleted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_flow
    ADD CONSTRAINT document_flow_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: document_flow document_flow_recipient_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_flow
    ADD CONSTRAINT document_flow_recipient_user_id_fkey FOREIGN KEY (recipient_user_id) REFERENCES public.users(id);


--
-- Name: document_flow document_flow_task_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_flow
    ADD CONSTRAINT document_flow_task_id_foreign FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: document_numbers document_numbers_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_numbers
    ADD CONSTRAINT document_numbers_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_numbers document_numbers_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_numbers
    ADD CONSTRAINT document_numbers_department_id_foreign FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: document_outgoing_changes document_outgoing_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_outgoing_changes
    ADD CONSTRAINT document_outgoing_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_outgoing_changes document_outgoing_changes_main_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_outgoing_changes
    ADD CONSTRAINT document_outgoing_changes_main_id_foreign FOREIGN KEY (main_id) REFERENCES public.document_outgoing(id);


--
-- Name: document_outgoing document_outgoing_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_outgoing
    ADD CONSTRAINT document_outgoing_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_outgoing document_outgoing_delivery_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_outgoing
    ADD CONSTRAINT document_outgoing_delivery_type_id_fkey FOREIGN KEY (delivery_type_id) REFERENCES public.delivery_type(id);


--
-- Name: document_outgoing document_outgoing_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_outgoing
    ADD CONSTRAINT document_outgoing_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: document_outgoing document_outgoing_recipient_db_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_outgoing
    ADD CONSTRAINT document_outgoing_recipient_db_id_foreign FOREIGN KEY (recipient_db_id) REFERENCES public.organizations(id);


--
-- Name: document_outgoing document_outgoing_response_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_outgoing
    ADD CONSTRAINT document_outgoing_response_document_id_foreign FOREIGN KEY (response_document_id) REFERENCES public.documents(id);


--
-- Name: document_outgoing document_outgoing_sender_db_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_outgoing
    ADD CONSTRAINT document_outgoing_sender_db_id_foreign FOREIGN KEY (sender_db_id) REFERENCES public.organizations(id);


--
-- Name: document_outgoing document_outgoing_sender_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_outgoing
    ADD CONSTRAINT document_outgoing_sender_department_id_foreign FOREIGN KEY (sender_department_id) REFERENCES public.departments(id);


--
-- Name: document_outgoing document_outgoing_sender_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_outgoing
    ADD CONSTRAINT document_outgoing_sender_user_id_foreign FOREIGN KEY (sender_user_id) REFERENCES public.users(id);


--
-- Name: document_permissions document_permissions_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_permissions
    ADD CONSTRAINT document_permissions_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_permissions document_permissions_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_permissions
    ADD CONSTRAINT document_permissions_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: document_permissions document_permissions_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_permissions
    ADD CONSTRAINT document_permissions_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: document_qr_code document_qr_code_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_qr_code
    ADD CONSTRAINT document_qr_code_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_qr_code document_qr_code_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_qr_code
    ADD CONSTRAINT document_qr_code_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: document_qr_code document_qr_code_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_qr_code
    ADD CONSTRAINT document_qr_code_file_id_foreign FOREIGN KEY (file_id) REFERENCES public.files(id);


--
-- Name: document_read_logs document_read_logs_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_read_logs
    ADD CONSTRAINT document_read_logs_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: document_read_logs document_read_logs_viewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_read_logs
    ADD CONSTRAINT document_read_logs_viewed_by_fkey FOREIGN KEY (read_by) REFERENCES public.users(id);


--
-- Name: document_receiver_groups_for_send_sign_changes document_receiver_groups_for_send_sign_changes_created_by_forei; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_receiver_groups_for_send_sign_changes
    ADD CONSTRAINT document_receiver_groups_for_send_sign_changes_created_by_forei FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_receiver_groups_for_send_sign document_receiver_groups_for_send_sign_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_receiver_groups_for_send_sign
    ADD CONSTRAINT document_receiver_groups_for_send_sign_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_send document_resolution_action_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send
    ADD CONSTRAINT document_resolution_action_by_foreign FOREIGN KEY (action_by) REFERENCES public.users(id);


--
-- Name: document_send_staged document_resolution_action_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_staged
    ADD CONSTRAINT document_resolution_action_by_foreign FOREIGN KEY (action_by) REFERENCES public.users(id);


--
-- Name: document_send document_resolution_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send
    ADD CONSTRAINT document_resolution_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_send_staged document_resolution_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_staged
    ADD CONSTRAINT document_resolution_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_send document_resolution_recipient_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send
    ADD CONSTRAINT document_resolution_recipient_user_id_foreign FOREIGN KEY (recipient_user_id) REFERENCES public.users(id);


--
-- Name: document_send_staged document_resolution_recipient_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_staged
    ADD CONSTRAINT document_resolution_recipient_user_id_foreign FOREIGN KEY (recipient_user_id) REFERENCES public.users(id);


--
-- Name: document_send document_resolution_resolution_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send
    ADD CONSTRAINT document_resolution_resolution_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: document_send_staged document_resolution_resolution_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_staged
    ADD CONSTRAINT document_resolution_resolution_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: document_send_changes document_send_changes_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_changes
    ADD CONSTRAINT document_send_changes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_send document_send_doc_signer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send
    ADD CONSTRAINT document_send_doc_signer_id_fkey FOREIGN KEY (doc_signer_id) REFERENCES public.document_signers(id);


--
-- Name: document_send document_send_fk_org_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send
    ADD CONSTRAINT document_send_fk_org_id FOREIGN KEY (doc_signer_org_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: document_send_staged document_send_fk_org_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_staged
    ADD CONSTRAINT document_send_fk_org_id FOREIGN KEY (doc_signer_org_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: document_send document_send_recipient_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send
    ADD CONSTRAINT document_send_recipient_department_id_foreign FOREIGN KEY (recipient_department_id) REFERENCES public.departments(id);


--
-- Name: document_send_staged document_send_recipient_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_staged
    ADD CONSTRAINT document_send_recipient_department_id_foreign FOREIGN KEY (recipient_department_id) REFERENCES public.departments(id);


--
-- Name: document_send_signature_changes document_send_signature_changes_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_signature_changes
    ADD CONSTRAINT document_send_signature_changes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_send_signature document_send_signature_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_signature
    ADD CONSTRAINT document_send_signature_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: document_send_staged document_send_staged_doc_signer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_staged
    ADD CONSTRAINT document_send_staged_doc_signer_id_fkey FOREIGN KEY (doc_signer_id) REFERENCES public.document_signers(id);


--
-- Name: document_send_signature document_signature_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_signature
    ADD CONSTRAINT document_signature_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_send_signature document_signature_document_send_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_signature
    ADD CONSTRAINT document_signature_document_send_id_foreign FOREIGN KEY (document_send_id) REFERENCES public.document_send(id);


--
-- Name: document_send_signature document_signature_output_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_send_signature
    ADD CONSTRAINT document_signature_output_file_id_foreign FOREIGN KEY (output_file_id) REFERENCES public.files(id);


--
-- Name: document_signers document_signers_fk_org_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_signers
    ADD CONSTRAINT document_signers_fk_org_id FOREIGN KEY (org_id) REFERENCES public.organizations(id) ON DELETE RESTRICT;


--
-- Name: document_signers_staged document_signers_fk_org_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_signers_staged
    ADD CONSTRAINT document_signers_fk_org_id FOREIGN KEY (org_id) REFERENCES public.organizations(id) ON DELETE RESTRICT;


--
-- Name: document_signers document_signers_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_signers
    ADD CONSTRAINT document_signers_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: document_signers_staged document_signers_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_signers_staged
    ADD CONSTRAINT document_signers_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: document_signers document_signers_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_signers
    ADD CONSTRAINT document_signers_users_id_fk FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: document_signers_staged document_signers_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_signers_staged
    ADD CONSTRAINT document_signers_users_id_fk FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: document_subject_changes document_subject_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_subject_changes
    ADD CONSTRAINT document_subject_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: document_subject_changes document_subject_changes_main_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_subject_changes
    ADD CONSTRAINT document_subject_changes_main_id_foreign FOREIGN KEY (main_id) REFERENCES public.document_subject(id) ON DELETE SET NULL;


--
-- Name: document_subject document_subject_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_subject
    ADD CONSTRAINT document_subject_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: document_subject document_subject_document_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_subject
    ADD CONSTRAINT document_subject_document_type_id_foreign FOREIGN KEY (document_type_id) REFERENCES public.document_types(id);


--
-- Name: document_types document_types_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.document_types
    ADD CONSTRAINT document_types_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: documents_count documents_count_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents_count
    ADD CONSTRAINT documents_count_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: documents_count documents_count_internal_doc_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents_count
    ADD CONSTRAINT documents_count_internal_doc_type_id_foreign FOREIGN KEY (internal_doc_type_id) REFERENCES public.internal_doc_types(id);


--
-- Name: documents documents_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: documents documents_deleted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: documents documents_internal_doc_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_internal_doc_type_id_foreign FOREIGN KEY (internal_doc_type_id) REFERENCES public.internal_doc_types(id);


--
-- Name: documents documents_journal_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_journal_id_foreign FOREIGN KEY (journal_id) REFERENCES public.journal(id);


--
-- Name: documents documents_main_signer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_main_signer_id_fkey FOREIGN KEY (main_signer_id) REFERENCES public.document_signers(id);


--
-- Name: documents documents_parent_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_parent_document_id_foreign FOREIGN KEY (parent_document_id) REFERENCES public.documents(id);


--
-- Name: documents documents_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_type_id_foreign FOREIGN KEY (type_id) REFERENCES public.document_types(id);


--
-- Name: docx_file_annotations docx_file_annotations_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.docx_file_annotations
    ADD CONSTRAINT docx_file_annotations_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: docx_file_annotations docx_file_annotations_updated_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.docx_file_annotations
    ADD CONSTRAINT docx_file_annotations_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: download_logs download_logs_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.download_logs
    ADD CONSTRAINT download_logs_file_id_foreign FOREIGN KEY (file_id) REFERENCES public.users(id);


--
-- Name: download_logs download_logs_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.download_logs
    ADD CONSTRAINT download_logs_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: drawing_journal_number_changes drawing_journal_number_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drawing_journal_number_changes
    ADD CONSTRAINT drawing_journal_number_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: drawing_journal_number_changes drawing_journal_number_changes_main_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drawing_journal_number_changes
    ADD CONSTRAINT drawing_journal_number_changes_main_id_foreign FOREIGN KEY (main_id) REFERENCES public.drawing_journal_number_gen(id);


--
-- Name: drawing_journal_number_gen drawing_journal_number_gen_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drawing_journal_number_gen
    ADD CONSTRAINT drawing_journal_number_gen_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: drawing_journal_number_gen drawing_journal_number_gen_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drawing_journal_number_gen
    ADD CONSTRAINT drawing_journal_number_gen_department_id_foreign FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: drawing_journal_number_gen drawing_journal_number_gen_doc_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drawing_journal_number_gen
    ADD CONSTRAINT drawing_journal_number_gen_doc_type_id_foreign FOREIGN KEY (doc_type_id) REFERENCES public.document_types(id);


--
-- Name: drawing_journal_number_gen drawing_journal_number_gen_journal_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drawing_journal_number_gen
    ADD CONSTRAINT drawing_journal_number_gen_journal_id_foreign FOREIGN KEY (journal_id) REFERENCES public.journal(id);


--
-- Name: drawing_journal_number_gen drawing_journal_number_gen_sign_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drawing_journal_number_gen
    ADD CONSTRAINT drawing_journal_number_gen_sign_user_id_foreign FOREIGN KEY (sign_user_id) REFERENCES public.users(id);


--
-- Name: drawing_journal_number_gen drawing_journal_number_gen_work_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drawing_journal_number_gen
    ADD CONSTRAINT drawing_journal_number_gen_work_user_id_foreign FOREIGN KEY (work_user_id) REFERENCES public.users(id);


--
-- Name: duty_schedule_group duty_schedule_group_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.duty_schedule_group
    ADD CONSTRAINT duty_schedule_group_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: duty_schedule_group duty_schedule_group_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.duty_schedule_group
    ADD CONSTRAINT duty_schedule_group_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.duty_schedule_group(id);


--
-- Name: duty_schedule_group duty_schedule_group_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.duty_schedule_group
    ADD CONSTRAINT duty_schedule_group_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: duty_schedule_groups_users duty_schedule_groups_users_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.duty_schedule_groups_users
    ADD CONSTRAINT duty_schedule_groups_users_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: duty_schedule_groups_users duty_schedule_groups_users_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.duty_schedule_groups_users
    ADD CONSTRAINT duty_schedule_groups_users_group_id_foreign FOREIGN KEY (group_id) REFERENCES public.duty_schedule_group(id);


--
-- Name: execution_control_tabs execution_control_tabs_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.execution_control_tabs
    ADD CONSTRAINT execution_control_tabs_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: favorite_organizations favorite_organizations_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_organizations
    ADD CONSTRAINT favorite_organizations_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: favorite_organizations favorite_organizations_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_organizations
    ADD CONSTRAINT favorite_organizations_department_id_foreign FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: favorite_organizations favorite_organizations_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_organizations
    ADD CONSTRAINT favorite_organizations_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: favorite_tasks favorite_tasks_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_tasks
    ADD CONSTRAINT favorite_tasks_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: favorite_tasks favorite_tasks_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_tasks
    ADD CONSTRAINT favorite_tasks_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: favorite_tasks favorite_tasks_recipient_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_tasks
    ADD CONSTRAINT favorite_tasks_recipient_id_foreign FOREIGN KEY (recipient_id) REFERENCES public.task_recipients(id);


--
-- Name: favorite_tasks favorite_tasks_task_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorite_tasks
    ADD CONSTRAINT favorite_tasks_task_id_foreign FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: files files_file_host_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_file_host_id_foreign FOREIGN KEY (file_host_id) REFERENCES public.file_host(id);


--
-- Name: event_pool fk_event_pool_event_handler_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_pool
    ADD CONSTRAINT fk_event_pool_event_handler_id FOREIGN KEY (event_handler_id) REFERENCES public.event_handlers(id) ON DELETE SET NULL;


--
-- Name: linked_document fk_linked_document_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linked_document
    ADD CONSTRAINT fk_linked_document_id FOREIGN KEY (linked_document_id) REFERENCES public.documents(id);


--
-- Name: nomenclatures fk_nomenclatures_created_by; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nomenclatures
    ADD CONSTRAINT fk_nomenclatures_created_by FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: nomenclatures fk_nomenclatures_db_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nomenclatures
    ADD CONSTRAINT fk_nomenclatures_db_id FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: nomenclatures fk_nomenclatures_deleted_by; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nomenclatures
    ADD CONSTRAINT fk_nomenclatures_deleted_by FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: staffing_positions fk_sp_category; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffing_positions
    ADD CONSTRAINT fk_sp_category FOREIGN KEY (category_id) REFERENCES public.staffing_position_categories(id);


--
-- Name: static_files fk_static_files_file_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_files
    ADD CONSTRAINT fk_static_files_file_id FOREIGN KEY (file_id) REFERENCES public.files(id) ON DELETE CASCADE;


--
-- Name: static_files fk_static_files_updated_by; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_files
    ADD CONSTRAINT fk_static_files_updated_by FOREIGN KEY (updated_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: documents fk_subject_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT fk_subject_id FOREIGN KEY (subject_id) REFERENCES public.document_subject(id);


--
-- Name: terms fk_terms_reference_type_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.terms
    ADD CONSTRAINT fk_terms_reference_type_id FOREIGN KEY (reference_type_id) REFERENCES public.reference_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: CONSTRAINT fk_terms_reference_type_id ON terms; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON CONSTRAINT fk_terms_reference_type_id ON public.terms IS 'Ensures that terms reference an existing reference_type. Type data is stored only in reference_types table.';


--
-- Name: fraction_members fraction_members_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fraction_members
    ADD CONSTRAINT fraction_members_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: fraction_members fraction_members_director_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fraction_members
    ADD CONSTRAINT fraction_members_director_user_id_foreign FOREIGN KEY (director_user_id) REFERENCES public.users(id);


--
-- Name: generate_journal_number_change generate_journal_number_change_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generate_journal_number_change
    ADD CONSTRAINT generate_journal_number_change_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: generate_journal_number_change generate_journal_number_change_generate_journal_number_id_forei; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generate_journal_number_change
    ADD CONSTRAINT generate_journal_number_change_generate_journal_number_id_forei FOREIGN KEY (generate_journal_number_id) REFERENCES public.generate_journal_number(id);


--
-- Name: generate_journal_number_change generate_journal_number_change_journal_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generate_journal_number_change
    ADD CONSTRAINT generate_journal_number_change_journal_id_foreign FOREIGN KEY (journal_id) REFERENCES public.journal(id);


--
-- Name: generate_journal_number generate_journal_number_journal_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generate_journal_number
    ADD CONSTRAINT generate_journal_number_journal_id_foreign FOREIGN KEY (journal_id) REFERENCES public.journal(id);


--
-- Name: generate_journal_number_list generate_journal_number_list_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generate_journal_number_list
    ADD CONSTRAINT generate_journal_number_list_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: generate_journal_number_list generate_journal_number_list_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generate_journal_number_list
    ADD CONSTRAINT generate_journal_number_list_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: generate_journal_number_list generate_journal_number_list_journal_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.generate_journal_number_list
    ADD CONSTRAINT generate_journal_number_list_journal_id_foreign FOREIGN KEY (journal_id) REFERENCES public.journal(id);


--
-- Name: guest_documents guest_documents_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_documents
    ADD CONSTRAINT guest_documents_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: guest_documents guest_documents_guest_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_documents
    ADD CONSTRAINT guest_documents_guest_id_foreign FOREIGN KEY (guest_id) REFERENCES public.guests(id);


--
-- Name: guest_request_approvals guest_request_approvals_approver_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_request_approvals
    ADD CONSTRAINT guest_request_approvals_approver_id_foreign FOREIGN KEY (approver_id) REFERENCES public.users(id);


--
-- Name: guest_request_approvals guest_request_approvals_completion_approver_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_request_approvals
    ADD CONSTRAINT guest_request_approvals_completion_approver_id_foreign FOREIGN KEY (completion_approver_id) REFERENCES public.users(id);


--
-- Name: guest_request_approvals guest_request_approvals_guest_request_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_request_approvals
    ADD CONSTRAINT guest_request_approvals_guest_request_id_foreign FOREIGN KEY (guest_request_id) REFERENCES public.guest_requests(id);


--
-- Name: guest_request_approvals guest_request_approvals_rejected_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_request_approvals
    ADD CONSTRAINT guest_request_approvals_rejected_by_foreign FOREIGN KEY (rejected_by) REFERENCES public.users(id);


--
-- Name: guest_request_logs guest_request_logs_guest_request_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_request_logs
    ADD CONSTRAINT guest_request_logs_guest_request_id_foreign FOREIGN KEY (guest_request_id) REFERENCES public.guest_requests(id);


--
-- Name: guest_requests guest_requests_block_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_requests
    ADD CONSTRAINT guest_requests_block_id_foreign FOREIGN KEY (block_id) REFERENCES public.building_blocks(id);


--
-- Name: guest_requests guest_requests_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_requests
    ADD CONSTRAINT guest_requests_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: guest_requests guest_requests_guest_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_requests
    ADD CONSTRAINT guest_requests_guest_id_foreign FOREIGN KEY (guest_id) REFERENCES public.guests(id);


--
-- Name: guest_requests guest_requests_recipient_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guest_requests
    ADD CONSTRAINT guest_requests_recipient_user_id_foreign FOREIGN KEY (recipient_user_id) REFERENCES public.users(id);


--
-- Name: guests guests_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guests
    ADD CONSTRAINT guests_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: incoming_document_changes incoming_document_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoming_document_changes
    ADD CONSTRAINT incoming_document_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: incoming_documents incoming_documents_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoming_documents
    ADD CONSTRAINT incoming_documents_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: incoming_documents incoming_documents_delivery_type_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoming_documents
    ADD CONSTRAINT incoming_documents_delivery_type_foreign FOREIGN KEY (delivery_type_id) REFERENCES public.delivery_type(id);


--
-- Name: incoming_documents incoming_documents_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incoming_documents
    ADD CONSTRAINT incoming_documents_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: initiative_doc_recipients initiative_doc_recipients_initiative_doc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.initiative_doc_recipients
    ADD CONSTRAINT initiative_doc_recipients_initiative_doc_id_fkey FOREIGN KEY (initiative_doc_id) REFERENCES public.initiative_nhh_docs(id);


--
-- Name: inner_document_type inner_document_type_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inner_document_type
    ADD CONSTRAINT inner_document_type_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: inner_document_type inner_document_type_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inner_document_type
    ADD CONSTRAINT inner_document_type_department_id_foreign FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: integration_settings integration_settings_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integration_settings
    ADD CONSTRAINT integration_settings_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.integration_settings(id) ON DELETE SET NULL;


--
-- Name: integrations integrations_integration_setting_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations
    ADD CONSTRAINT integrations_integration_setting_id_fkey FOREIGN KEY (integration_setting_id) REFERENCES public.integration_settings(id) ON DELETE SET NULL;


--
-- Name: integrations integrations_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.integrations
    ADD CONSTRAINT integrations_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.background_checks(id) ON DELETE CASCADE;


--
-- Name: internal_doc_type_changes internal_doc_type_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_doc_type_changes
    ADD CONSTRAINT internal_doc_type_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: internal_doc_types internal_doc_types_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_doc_types
    ADD CONSTRAINT internal_doc_types_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: internal_doc_types internal_doc_types_journal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_doc_types
    ADD CONSTRAINT internal_doc_types_journal_id_fkey FOREIGN KEY (journal_id) REFERENCES public.journal(id);


--
-- Name: internal_doc_types internal_doc_types_parent_doc_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_doc_types
    ADD CONSTRAINT internal_doc_types_parent_doc_type_id_foreign FOREIGN KEY (parent_doc_type_id) REFERENCES public.document_types(id);


--
-- Name: internal_document_changes internal_document_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_document_changes
    ADD CONSTRAINT internal_document_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: internal_documents internal_documents_main_signer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_documents
    ADD CONSTRAINT internal_documents_main_signer_id_foreign FOREIGN KEY (main_signer_id) REFERENCES public.document_signers(id);


--
-- Name: journal_changes journal_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_changes
    ADD CONSTRAINT journal_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: journal_changes journal_changes_main_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal_changes
    ADD CONSTRAINT journal_changes_main_id_foreign FOREIGN KEY (main_id) REFERENCES public.journal(id);


--
-- Name: journal journal_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal
    ADD CONSTRAINT journal_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: journal journal_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.journal
    ADD CONSTRAINT journal_type_id_foreign FOREIGN KEY (doc_type_id) REFERENCES public.document_types(id);


--
-- Name: kpi_failed_transactions kpi_failed_transactions_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kpi_failed_transactions
    ADD CONSTRAINT kpi_failed_transactions_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: kpi_failed_transactions kpi_failed_transactions_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kpi_failed_transactions
    ADD CONSTRAINT kpi_failed_transactions_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: kpi_transactions kpi_transactions_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kpi_transactions
    ADD CONSTRAINT kpi_transactions_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: kpi_transactions kpi_transactions_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kpi_transactions
    ADD CONSTRAINT kpi_transactions_department_id_foreign FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: kpi_transactions kpi_transactions_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kpi_transactions
    ADD CONSTRAINT kpi_transactions_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: kpi_transactions kpi_transactions_recipient_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kpi_transactions
    ADD CONSTRAINT kpi_transactions_recipient_id_foreign FOREIGN KEY (recipient_id) REFERENCES public.task_recipients(id);


--
-- Name: kpi_transactions kpi_transactions_request_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kpi_transactions
    ADD CONSTRAINT kpi_transactions_request_id_foreign FOREIGN KEY (request_id) REFERENCES public.task_requests(id);


--
-- Name: kpi_transactions kpi_transactions_send_action_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kpi_transactions
    ADD CONSTRAINT kpi_transactions_send_action_id_foreign FOREIGN KEY (send_action_id) REFERENCES public.recipient_answer_actions(id);


--
-- Name: kpi_transactions kpi_transactions_task_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kpi_transactions
    ADD CONSTRAINT kpi_transactions_task_id_foreign FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: kpi_transactions kpi_transactions_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.kpi_transactions
    ADD CONSTRAINT kpi_transactions_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: labels labels_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.labels
    ADD CONSTRAINT labels_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: labels labels_deleted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.labels
    ADD CONSTRAINT labels_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: labels labels_updated_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.labels
    ADD CONSTRAINT labels_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: linked_document linked_document_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.linked_document
    ADD CONSTRAINT linked_document_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: members members_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: news news_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news
    ADD CONSTRAINT news_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: news news_db_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news
    ADD CONSTRAINT news_db_id_fkey FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: news_read_logs news_read_logs_news_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_read_logs
    ADD CONSTRAINT news_read_logs_news_id_fkey FOREIGN KEY (news_id) REFERENCES public.news(id) ON DELETE CASCADE;


--
-- Name: news_read_logs news_read_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_read_logs
    ADD CONSTRAINT news_read_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: newspapers newspapers_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspapers
    ADD CONSTRAINT newspapers_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: newspapers newspapers_db_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspapers
    ADD CONSTRAINT newspapers_db_id_foreign FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: newspapers newspapers_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.newspapers
    ADD CONSTRAINT newspapers_file_id_foreign FOREIGN KEY (file_id) REFERENCES public.files(id);


--
-- Name: nhh_agreement_changes nhh_agreement_changes_main_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_agreement_changes
    ADD CONSTRAINT nhh_agreement_changes_main_id_fkey FOREIGN KEY (main_id) REFERENCES public.nhh_agreements(id);


--
-- Name: nhh_agreements nhh_agreements_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_agreements
    ADD CONSTRAINT nhh_agreements_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: nhh_kpi_document_setting_changes nhh_kpi_document_setting_changes_main_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_document_setting_changes
    ADD CONSTRAINT nhh_kpi_document_setting_changes_main_id_fkey FOREIGN KEY (main_id) REFERENCES public.nhh_kpi_document_settings(id);


--
-- Name: nhh_kpi_document_settings nhh_kpi_document_settings_kpi_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_document_settings
    ADD CONSTRAINT nhh_kpi_document_settings_kpi_type_id_fkey FOREIGN KEY (kpi_type_id) REFERENCES public.nhh_kpi_types(id);


--
-- Name: nhh_kpi_due_date_ranges nhh_kpi_due_date_ranges_kpi_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_due_date_ranges
    ADD CONSTRAINT nhh_kpi_due_date_ranges_kpi_type_id_fkey FOREIGN KEY (kpi_type_id) REFERENCES public.nhh_kpi_types(id);


--
-- Name: nhh_kpi_due_date_ranges nhh_kpi_due_date_ranges_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_due_date_ranges
    ADD CONSTRAINT nhh_kpi_due_date_ranges_version_id_fkey FOREIGN KEY (version_id) REFERENCES public.nhh_kpi_versions(id);


--
-- Name: nhh_kpi_records nhh_kpi_records_kpi_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_records
    ADD CONSTRAINT nhh_kpi_records_kpi_type_id_fkey FOREIGN KEY (kpi_type_id) REFERENCES public.nhh_kpi_types(id);


--
-- Name: nhh_kpi_records nhh_kpi_records_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_records
    ADD CONSTRAINT nhh_kpi_records_version_id_fkey FOREIGN KEY (version_id) REFERENCES public.nhh_kpi_versions(id);


--
-- Name: nhh_kpi_type_changes nhh_kpi_type_changes_main_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_type_changes
    ADD CONSTRAINT nhh_kpi_type_changes_main_id_fkey FOREIGN KEY (main_id) REFERENCES public.nhh_kpi_types(id);


--
-- Name: nhh_kpi_type_config_changes nhh_kpi_type_config_changes_main_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_type_config_changes
    ADD CONSTRAINT nhh_kpi_type_config_changes_main_id_fkey FOREIGN KEY (main_id) REFERENCES public.nhh_kpi_type_configs(id);


--
-- Name: nhh_kpi_type_configs nhh_kpi_type_configs_kpi_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_type_configs
    ADD CONSTRAINT nhh_kpi_type_configs_kpi_type_id_fkey FOREIGN KEY (kpi_type_id) REFERENCES public.nhh_kpi_types(id);


--
-- Name: nhh_kpi_type_configs nhh_kpi_type_configs_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_type_configs
    ADD CONSTRAINT nhh_kpi_type_configs_version_id_fkey FOREIGN KEY (version_id) REFERENCES public.nhh_kpi_versions(id);


--
-- Name: nhh_kpi_type_group_changes nhh_kpi_type_group_changes_main_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_type_group_changes
    ADD CONSTRAINT nhh_kpi_type_group_changes_main_id_fkey FOREIGN KEY (main_id) REFERENCES public.nhh_kpi_type_groups(id);


--
-- Name: nhh_kpi_types nhh_kpi_types_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_types
    ADD CONSTRAINT nhh_kpi_types_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.nhh_kpi_type_groups(id);


--
-- Name: nhh_kpi_version_changes nhh_kpi_version_changes_main_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nhh_kpi_version_changes
    ADD CONSTRAINT nhh_kpi_version_changes_main_id_fkey FOREIGN KEY (main_id) REFERENCES public.nhh_kpi_versions(id);


--
-- Name: normative_doc_bases normative_doc_bases_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.normative_doc_bases
    ADD CONSTRAINT normative_doc_bases_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: normative_document_changes normative_document_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.normative_document_changes
    ADD CONSTRAINT normative_document_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: normative_document_changes normative_document_changes_main_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.normative_document_changes
    ADD CONSTRAINT normative_document_changes_main_id_foreign FOREIGN KEY (main_id) REFERENCES public.normative_documents(id);


--
-- Name: normative_documents normative_documents_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.normative_documents
    ADD CONSTRAINT normative_documents_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: normative_documents normative_documents_deleted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.normative_documents
    ADD CONSTRAINT normative_documents_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: normative_documents normative_documents_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.normative_documents
    ADD CONSTRAINT normative_documents_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: normative_legal_docs_tasks normative_legal_docs_tasks_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.normative_legal_docs_tasks
    ADD CONSTRAINT normative_legal_docs_tasks_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: normative_legal_docs_tasks normative_legal_docs_tasks_deleted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.normative_legal_docs_tasks
    ADD CONSTRAINT normative_legal_docs_tasks_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: normative_legal_docs_tasks normative_legal_docs_tasks_last_updated_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.normative_legal_docs_tasks
    ADD CONSTRAINT normative_legal_docs_tasks_last_updated_by_foreign FOREIGN KEY (last_updated_by) REFERENCES public.users(id);


--
-- Name: normative_legal_docs_tasks normative_legal_docs_tasks_recipient_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.normative_legal_docs_tasks
    ADD CONSTRAINT normative_legal_docs_tasks_recipient_user_id_foreign FOREIGN KEY (recipient_user_id) REFERENCES public.users(id);


--
-- Name: notifications notifications_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: notifications notifications_deleted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: notifications notifications_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: notifications notifications_task_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_task_id_foreign FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: org_connection_type org_connection_type_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org_connection_type
    ADD CONSTRAINT org_connection_type_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: org_contact org_contact_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.org_contact
    ADD CONSTRAINT org_contact_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: organization_chief organization_chief_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_chief
    ADD CONSTRAINT organization_chief_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: organization_chief organization_chief_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_chief
    ADD CONSTRAINT organization_chief_department_id_foreign FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: organization_chief organization_chief_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_chief
    ADD CONSTRAINT organization_chief_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: organization_types organization_types_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_types
    ADD CONSTRAINT organization_types_organization_id_foreign FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: organization_users organization_users_org_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_users
    ADD CONSTRAINT organization_users_org_id_foreign FOREIGN KEY (org_id) REFERENCES public.organizations(id);


--
-- Name: organization_weekends organization_weekends_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_weekends
    ADD CONSTRAINT organization_weekends_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: organization_weekends organization_weekends_updated_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_weekends
    ADD CONSTRAINT organization_weekends_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: organizational_structure organizational_structure_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizational_structure
    ADD CONSTRAINT organizational_structure_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: organizational_structure_draft organizational_structure_draft_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizational_structure_draft
    ADD CONSTRAINT organizational_structure_draft_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: organizations_1 organizations_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_1
    ADD CONSTRAINT organizations_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: organizations_1 organizations_district_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_1
    ADD CONSTRAINT organizations_district_id_foreign FOREIGN KEY (district_id) REFERENCES public.regions(id);


--
-- Name: organizations_1 organizations_region_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations_1
    ADD CONSTRAINT organizations_region_id_foreign FOREIGN KEY (region_id) REFERENCES public.regions(id);


--
-- Name: permissions permissions_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: permissions permissions_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_department_id_foreign FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: permissions permissions_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: permissions permissions_worker_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_worker_user_id_foreign FOREIGN KEY (worker_user_id) REFERENCES public.users(id);


--
-- Name: pkcs10_until_confirm pkcs10_until_confirm_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pkcs10_until_confirm
    ADD CONSTRAINT pkcs10_until_confirm_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: project_normative_document_changes project_normative_document_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_normative_document_changes
    ADD CONSTRAINT project_normative_document_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: project_normative_documents project_normative_documents_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_normative_documents
    ADD CONSTRAINT project_normative_documents_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: project_normative_documents project_normative_documents_developed_by_db_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_normative_documents
    ADD CONSTRAINT project_normative_documents_developed_by_db_id_foreign FOREIGN KEY (developed_by_db_id) REFERENCES public.organizations(id);


--
-- Name: project_normative_documents project_normative_documents_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_normative_documents
    ADD CONSTRAINT project_normative_documents_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: public_holidays public_holidays_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_holidays
    ADD CONSTRAINT public_holidays_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: published_doc_group_changes published_doc_group_changes_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.published_doc_group_changes
    ADD CONSTRAINT published_doc_group_changes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: published_doc_group_changes published_doc_group_changes_main_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.published_doc_group_changes
    ADD CONSTRAINT published_doc_group_changes_main_id_fkey FOREIGN KEY (main_id) REFERENCES public.published_document_groups(id);


--
-- Name: published_document_groups published_document_groups_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.published_document_groups
    ADD CONSTRAINT published_document_groups_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: published_document_groups published_document_groups_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.published_document_groups
    ADD CONSTRAINT published_document_groups_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.published_document_groups(id);


--
-- Name: read_logs read_logs_read_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.read_logs
    ADD CONSTRAINT read_logs_read_by_foreign FOREIGN KEY (read_by) REFERENCES public.users(id);


--
-- Name: recipient_answer_actions recipient_answer_actions_copy_from_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT recipient_answer_actions_copy_from_id_foreign FOREIGN KEY (copy_from_id) REFERENCES public.recipient_answer_actions(id);


--
-- Name: recipient_answer_actions recipient_answer_actions_recipient_answer_actions_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT recipient_answer_actions_recipient_answer_actions_id_fk FOREIGN KEY (copy_from_id) REFERENCES public.recipient_answer_actions(id);


--
-- Name: recipient_answer_draft_until_sign recipient_answer_draft_until_sign_answer_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_draft_until_sign
    ADD CONSTRAINT recipient_answer_draft_until_sign_answer_document_id_fkey FOREIGN KEY (answer_document_id) REFERENCES public.documents(id);


--
-- Name: recipient_answer_draft_until_sign recipient_asnwer_draft_until_sign_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_draft_until_sign
    ADD CONSTRAINT recipient_asnwer_draft_until_sign_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: recipient_answer_draft_until_sign recipient_asnwer_draft_until_sign_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_draft_until_sign
    ADD CONSTRAINT recipient_asnwer_draft_until_sign_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: recipient_answer_draft_until_sign recipient_asnwer_draft_until_sign_recipient_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_draft_until_sign
    ADD CONSTRAINT recipient_asnwer_draft_until_sign_recipient_id_foreign FOREIGN KEY (recipient_id) REFERENCES public.task_recipients(id);


--
-- Name: recipient_answer_draft_until_sign recipient_asnwer_draft_until_sign_task_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_draft_until_sign
    ADD CONSTRAINT recipient_asnwer_draft_until_sign_task_id_foreign FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: recipient_changes recipient_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_changes
    ADD CONSTRAINT recipient_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: recipient_changes recipient_changes_main_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_changes
    ADD CONSTRAINT recipient_changes_main_id_foreign FOREIGN KEY (main_id) REFERENCES public.task_recipients(id);


--
-- Name: recipient_orgs_group recipient_orgs_group_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_orgs_group
    ADD CONSTRAINT recipient_orgs_group_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: recipient_orgs_group recipient_orgs_group_deleted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_orgs_group
    ADD CONSTRAINT recipient_orgs_group_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: recipient_orgs_group recipient_orgs_group_updated_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_orgs_group
    ADD CONSTRAINT recipient_orgs_group_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: recipients_group recipients_group_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipients_group
    ADD CONSTRAINT recipients_group_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: recipients_group recipients_group_deleted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipients_group
    ADD CONSTRAINT recipients_group_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: record_history record_history_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_history
    ADD CONSTRAINT record_history_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: record_history record_history_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_history
    ADD CONSTRAINT record_history_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE SET NULL;


--
-- Name: record_history record_history_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_history
    ADD CONSTRAINT record_history_record_id_fkey FOREIGN KEY (record_id) REFERENCES public.records(id) ON DELETE CASCADE;


--
-- Name: record_history record_history_record_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_history
    ADD CONSTRAINT record_history_record_type_id_fkey FOREIGN KEY (record_type_id) REFERENCES public.record_types(id) ON DELETE CASCADE;


--
-- Name: record_types record_types_db_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_types
    ADD CONSTRAINT record_types_db_id_fkey FOREIGN KEY (db_id) REFERENCES public.organizations(id) ON DELETE SET NULL;


--
-- Name: record_types record_types_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_types
    ADD CONSTRAINT record_types_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE SET NULL;


--
-- Name: records records_completed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.records
    ADD CONSTRAINT records_completed_by_fkey FOREIGN KEY (completed_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: records records_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.records
    ADD CONSTRAINT records_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: records records_db_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.records
    ADD CONSTRAINT records_db_id_fkey FOREIGN KEY (db_id) REFERENCES public.organizations(id) ON DELETE SET NULL;


--
-- Name: records records_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.records
    ADD CONSTRAINT records_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: records records_locked_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.records
    ADD CONSTRAINT records_locked_by_fkey FOREIGN KEY (locked_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: records records_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.records
    ADD CONSTRAINT records_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE SET NULL;


--
-- Name: records records_record_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.records
    ADD CONSTRAINT records_record_type_id_fkey FOREIGN KEY (record_type_id) REFERENCES public.record_types(id) ON DELETE CASCADE;


--
-- Name: records records_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.records
    ADD CONSTRAINT records_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: regions regions_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: reject_for_sign reject_for_sign_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reject_for_sign
    ADD CONSTRAINT reject_for_sign_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: reject_for_sign reject_for_sign_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reject_for_sign
    ADD CONSTRAINT reject_for_sign_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: reject_for_sign reject_for_sign_updated_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reject_for_sign
    ADD CONSTRAINT reject_for_sign_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: repeatable_plan_changes repeatable_plan_changes_created_by_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_plan_changes
    ADD CONSTRAINT repeatable_plan_changes_created_by_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: repeatable_plan_changes repeatable_plan_changes_db_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_plan_changes
    ADD CONSTRAINT repeatable_plan_changes_db_id_fk FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: repeatable_plan_changes repeatable_plan_changes_plan_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_plan_changes
    ADD CONSTRAINT repeatable_plan_changes_plan_id_fk FOREIGN KEY (plan_id) REFERENCES public.repeatable_plan(id);


--
-- Name: repeatable_plan repeatable_plan_created_by_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_plan
    ADD CONSTRAINT repeatable_plan_created_by_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: repeatable_plan repeatable_plan_db_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_plan
    ADD CONSTRAINT repeatable_plan_db_id_fk FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: repeatable_plan repeatable_plan_document_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_plan
    ADD CONSTRAINT repeatable_plan_document_id_fk FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: repeatable_plan repeatable_plan_first_task_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_plan
    ADD CONSTRAINT repeatable_plan_first_task_id_fk FOREIGN KEY (first_task_id) REFERENCES public.tasks(id);


--
-- Name: repeatable_plan repeatable_plan_updated_by_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_plan
    ADD CONSTRAINT repeatable_plan_updated_by_fk FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: repeatable_task repeatable_task_active_task_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_task
    ADD CONSTRAINT repeatable_task_active_task_id_fk FOREIGN KEY (active_task_id) REFERENCES public.tasks(id);


--
-- Name: repeatable_task repeatable_task_created_by_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_task
    ADD CONSTRAINT repeatable_task_created_by_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: repeatable_task_cron repeatable_task_cron_created_by_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_task_cron
    ADD CONSTRAINT repeatable_task_cron_created_by_fk FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: repeatable_task_cron repeatable_task_cron_db_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_task_cron
    ADD CONSTRAINT repeatable_task_cron_db_id_fk FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: repeatable_task_cron repeatable_task_cron_updated_by_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_task_cron
    ADD CONSTRAINT repeatable_task_cron_updated_by_fk FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: repeatable_task repeatable_task_db_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_task
    ADD CONSTRAINT repeatable_task_db_id_fk FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: repeatable_task repeatable_task_document_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_task
    ADD CONSTRAINT repeatable_task_document_id_fk FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: repeatable_task repeatable_task_plan_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_task
    ADD CONSTRAINT repeatable_task_plan_id_fk FOREIGN KEY (plan_id) REFERENCES public.repeatable_plan(id);


--
-- Name: repeatable_task repeatable_task_updated_by_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repeatable_task
    ADD CONSTRAINT repeatable_task_updated_by_fk FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: request_draft_until_sign request_draft_until_sign_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_draft_until_sign
    ADD CONSTRAINT request_draft_until_sign_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: request_draft_until_sign request_draft_until_sign_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_draft_until_sign
    ADD CONSTRAINT request_draft_until_sign_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: request_draft_until_sign request_draft_until_sign_recipient_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_draft_until_sign
    ADD CONSTRAINT request_draft_until_sign_recipient_id_foreign FOREIGN KEY (recipient_id) REFERENCES public.task_recipients(id);


--
-- Name: request_draft_until_sign request_draft_until_sign_task_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.request_draft_until_sign
    ADD CONSTRAINT request_draft_until_sign_task_id_foreign FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: resolution_template_body resolution_template_body_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resolution_template_body
    ADD CONSTRAINT resolution_template_body_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: resolution_template_body resolution_template_body_db_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resolution_template_body
    ADD CONSTRAINT resolution_template_body_db_id_foreign FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: resolution_template_body resolution_template_body_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resolution_template_body
    ADD CONSTRAINT resolution_template_body_department_id_foreign FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: resolution_template_body resolution_template_body_document_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resolution_template_body
    ADD CONSTRAINT resolution_template_body_document_type_id_foreign FOREIGN KEY (document_type_id) REFERENCES public.document_types(id);


--
-- Name: resolution_template_body resolution_template_body_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resolution_template_body
    ADD CONSTRAINT resolution_template_body_file_id_foreign FOREIGN KEY (file_id) REFERENCES public.files(id);


--
-- Name: resolution_template_changes resolution_template_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resolution_template_changes
    ADD CONSTRAINT resolution_template_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: resolution_template resolution_template_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resolution_template
    ADD CONSTRAINT resolution_template_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: resolution_template resolution_template_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resolution_template
    ADD CONSTRAINT resolution_template_file_id_foreign FOREIGN KEY (file_id) REFERENCES public.files(id);


--
-- Name: resolution_template resolution_template_header_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resolution_template
    ADD CONSTRAINT resolution_template_header_file_id_foreign FOREIGN KEY (header_file_id) REFERENCES public.files(id);


--
-- Name: resolution_template resolution_template_updated_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.resolution_template
    ADD CONSTRAINT resolution_template_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: role_changes role_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_changes
    ADD CONSTRAINT role_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: role_changes role_changes_main_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_changes
    ADD CONSTRAINT role_changes_main_id_foreign FOREIGN KEY (main_id) REFERENCES public.roles(id);


--
-- Name: role_permission_changes role_permission_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission_changes
    ADD CONSTRAINT role_permission_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: role_permission_changes role_permission_changes_main_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission_changes
    ADD CONSTRAINT role_permission_changes_main_id_foreign FOREIGN KEY (main_id) REFERENCES public.role_permissions(id);


--
-- Name: role_permission_list role_permission_list_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission_list
    ADD CONSTRAINT role_permission_list_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.role_permission_list(id);


--
-- Name: role_permissions role_permissions_permission_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_foreign FOREIGN KEY (permission_id) REFERENCES public.role_permission_list(id);


--
-- Name: role_permissions role_permissions_role_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_foreign FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: roles roles_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: roles roles_deleted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: send_changes send_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.send_changes
    ADD CONSTRAINT send_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: send_changes send_changes_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.send_changes
    ADD CONSTRAINT send_changes_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: send_changes send_changes_recipient_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.send_changes
    ADD CONSTRAINT send_changes_recipient_id_foreign FOREIGN KEY (recipient_id) REFERENCES public.task_recipients(id);


--
-- Name: send_changes send_changes_send_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.send_changes
    ADD CONSTRAINT send_changes_send_id_foreign FOREIGN KEY (send_id) REFERENCES public.recipient_answer_actions(id);


--
-- Name: send_changes send_changes_task_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.send_changes
    ADD CONSTRAINT send_changes_task_id_foreign FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: send_to_child_access send_to_child_access_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.send_to_child_access
    ADD CONSTRAINT send_to_child_access_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: send_to_child_access send_to_child_access_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.send_to_child_access
    ADD CONSTRAINT send_to_child_access_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: staffing_positions staffing_positions_order_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffing_positions
    ADD CONSTRAINT staffing_positions_order_document_id_fkey FOREIGN KEY (order_document_id) REFERENCES public.documents(id);


--
-- Name: staffing_positions staffing_positions_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffing_positions
    ADD CONSTRAINT staffing_positions_org_id_fkey FOREIGN KEY (db_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: staffing_positions staffing_positions_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffing_positions
    ADD CONSTRAINT staffing_positions_position_id_fkey FOREIGN KEY (position_id) REFERENCES public.positions(id) ON DELETE RESTRICT;


--
-- Name: staffing_positions staffing_positions_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staffing_positions
    ADD CONSTRAINT staffing_positions_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.structural_units(id) ON DELETE SET NULL;


--
-- Name: static_data static_data_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_data
    ADD CONSTRAINT static_data_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: static_data static_data_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.static_data
    ADD CONSTRAINT static_data_file_id_foreign FOREIGN KEY (file_id) REFERENCES public.files(id);


--
-- Name: structural_units structural_units_order_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.structural_units
    ADD CONSTRAINT structural_units_order_document_id_fkey FOREIGN KEY (order_document_id) REFERENCES public.documents(id);


--
-- Name: structural_units structural_units_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.structural_units
    ADD CONSTRAINT structural_units_org_id_fkey FOREIGN KEY (db_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: structural_units structural_units_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.structural_units
    ADD CONSTRAINT structural_units_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.structural_units(id) ON DELETE SET NULL;


--
-- Name: structural_units structural_units_unit_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.structural_units
    ADD CONSTRAINT structural_units_unit_type_id_fkey FOREIGN KEY (unit_type_id) REFERENCES public.unit_types(id);


--
-- Name: suggestions_changes suggestions_changes_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suggestions_changes
    ADD CONSTRAINT suggestions_changes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: suggestions suggestions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suggestions
    ADD CONSTRAINT suggestions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: suggestions suggestions_db_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suggestions
    ADD CONSTRAINT suggestions_db_id_fkey FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: sync_items sync_items_sync_packages_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sync_items
    ADD CONSTRAINT sync_items_sync_packages_id_fk FOREIGN KEY (package_id) REFERENCES public.sync_packages(id);


--
-- Name: task_changes task_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_changes
    ADD CONSTRAINT task_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: task_changes task_changes_main_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_changes
    ADD CONSTRAINT task_changes_main_id_foreign FOREIGN KEY (main_id) REFERENCES public.tasks(id);


--
-- Name: task_content_templates task_content_templates_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_content_templates
    ADD CONSTRAINT task_content_templates_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: task_content_templates task_content_templates_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_content_templates
    ADD CONSTRAINT task_content_templates_department_id_foreign FOREIGN KEY (department_id) REFERENCES public.departments(id);


--
-- Name: task_controllers task_controllers_controller_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_controllers
    ADD CONSTRAINT task_controllers_controller_department_id_foreign FOREIGN KEY (controller_department_id) REFERENCES public.departments(id);


--
-- Name: task_controllers task_controllers_controller_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_controllers
    ADD CONSTRAINT task_controllers_controller_user_id_foreign FOREIGN KEY (controller_user_id) REFERENCES public.users(id);


--
-- Name: task_controllers task_controllers_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_controllers
    ADD CONSTRAINT task_controllers_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: task_controllers task_controllers_deleted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_controllers
    ADD CONSTRAINT task_controllers_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: task_controllers task_controllers_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_controllers
    ADD CONSTRAINT task_controllers_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: task_controllers task_controllers_task_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_controllers
    ADD CONSTRAINT task_controllers_task_id_foreign FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: task_controllers task_controllers_updated_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_controllers
    ADD CONSTRAINT task_controllers_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: task_draft_until_sign task_draft_until_sign_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_draft_until_sign
    ADD CONSTRAINT task_draft_until_sign_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: task_recipients_count task_recipients_count_document_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients_count
    ADD CONSTRAINT task_recipients_count_document_type_id_foreign FOREIGN KEY (document_type_id) REFERENCES public.document_types(id);


--
-- Name: task_recipients_count task_recipients_count_internal_doc_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients_count
    ADD CONSTRAINT task_recipients_count_internal_doc_type_id_foreign FOREIGN KEY (internal_doc_type_id) REFERENCES public.internal_doc_types(id);


--
-- Name: task_recipients_count task_recipients_count_recipient_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients_count
    ADD CONSTRAINT task_recipients_count_recipient_department_id_foreign FOREIGN KEY (recipient_department_id) REFERENCES public.departments(id);


--
-- Name: task_recipients_count task_recipients_count_recipient_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients_count
    ADD CONSTRAINT task_recipients_count_recipient_user_id_foreign FOREIGN KEY (recipient_user_id) REFERENCES public.users(id);


--
-- Name: task_recipients_count task_recipients_count_sender_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients_count
    ADD CONSTRAINT task_recipients_count_sender_department_id_foreign FOREIGN KEY (sender_department_id) REFERENCES public.departments(id);


--
-- Name: task_recipients_count task_recipients_count_sender_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients_count
    ADD CONSTRAINT task_recipients_count_sender_user_id_foreign FOREIGN KEY (sender_user_id) REFERENCES public.users(id);


--
-- Name: task_recipients task_recipients_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients
    ADD CONSTRAINT task_recipients_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: task_recipients task_recipients_deleted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients
    ADD CONSTRAINT task_recipients_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: task_recipients task_recipients_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients
    ADD CONSTRAINT task_recipients_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: task_recipients task_recipients_done_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients
    ADD CONSTRAINT task_recipients_done_by_foreign FOREIGN KEY (done_by) REFERENCES public.users(id);


--
-- Name: task_recipients task_recipients_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients
    ADD CONSTRAINT task_recipients_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.task_recipients(id);


--
-- Name: task_recipients task_recipients_recipient_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients
    ADD CONSTRAINT task_recipients_recipient_department_id_foreign FOREIGN KEY (recipient_department_id) REFERENCES public.departments(id);


--
-- Name: task_recipients task_recipients_recipient_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients
    ADD CONSTRAINT task_recipients_recipient_user_id_foreign FOREIGN KEY (recipient_user_id) REFERENCES public.users(id);


--
-- Name: task_recipients task_recipients_sender_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients
    ADD CONSTRAINT task_recipients_sender_user_id_foreign FOREIGN KEY (sender_user_id) REFERENCES public.users(id);


--
-- Name: task_recipients task_recipients_task_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients
    ADD CONSTRAINT task_recipients_task_id_foreign FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: task_recipients task_recipients_updated_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_recipients
    ADD CONSTRAINT task_recipients_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: task_requests task_requests_copy_from_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_requests
    ADD CONSTRAINT task_requests_copy_from_id_foreign FOREIGN KEY (copy_from_id) REFERENCES public.task_requests(id);


--
-- Name: task_requests task_requests_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_requests
    ADD CONSTRAINT task_requests_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: task_requests task_requests_deleted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_requests
    ADD CONSTRAINT task_requests_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: task_requests task_requests_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_requests
    ADD CONSTRAINT task_requests_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: task_requests task_requests_document_send_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_requests
    ADD CONSTRAINT task_requests_document_send_id_fkey FOREIGN KEY (document_send_id) REFERENCES public.document_send(id);


--
-- Name: task_requests task_requests_recipient_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_requests
    ADD CONSTRAINT task_requests_recipient_id_foreign FOREIGN KEY (recipient_id) REFERENCES public.task_recipients(id);


--
-- Name: task_requests task_requests_request_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_requests
    ADD CONSTRAINT task_requests_request_document_id_foreign FOREIGN KEY (request_document_id) REFERENCES public.documents(id);


--
-- Name: task_requests task_requests_task_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.task_requests
    ADD CONSTRAINT task_requests_task_id_foreign FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: recipient_answer_actions task_send_copy_from_request_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT task_send_copy_from_request_id_foreign FOREIGN KEY (copy_from_id) REFERENCES public.recipient_answer_actions(id);


--
-- Name: recipient_answer_actions task_send_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT task_send_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: recipient_answer_actions task_send_deleted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT task_send_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: recipient_answer_actions task_send_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT task_send_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: recipient_answer_actions task_send_document_send_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT task_send_document_send_id_fkey FOREIGN KEY (document_send_id) REFERENCES public.document_send(id);


--
-- Name: recipient_answer_actions task_send_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT task_send_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.recipient_answer_actions(id);


--
-- Name: recipient_answer_actions task_send_recipient_db_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT task_send_recipient_db_id_foreign FOREIGN KEY (recipient_db_id) REFERENCES public.organizations(id);


--
-- Name: recipient_answer_actions task_send_recipient_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT task_send_recipient_department_id_foreign FOREIGN KEY (recipient_department_id) REFERENCES public.departments(id);


--
-- Name: recipient_answer_actions task_send_recipient_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT task_send_recipient_id_foreign FOREIGN KEY (recipient_id) REFERENCES public.task_recipients(id);


--
-- Name: recipient_answer_actions task_send_recipient_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT task_send_recipient_user_id_foreign FOREIGN KEY (recipient_user_id) REFERENCES public.users(id);


--
-- Name: recipient_answer_actions task_send_request_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT task_send_request_document_id_fkey FOREIGN KEY (answer_document_id) REFERENCES public.documents(id);


--
-- Name: recipient_answer_actions task_send_sender_db_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT task_send_sender_db_id_foreign FOREIGN KEY (sender_db_id) REFERENCES public.organizations(id);


--
-- Name: recipient_answer_actions task_send_sender_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT task_send_sender_department_id_foreign FOREIGN KEY (sender_department_id) REFERENCES public.departments(id);


--
-- Name: recipient_answer_actions task_send_sender_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT task_send_sender_user_id_foreign FOREIGN KEY (sender_user_id) REFERENCES public.users(id);


--
-- Name: recipient_answer_actions task_send_task_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recipient_answer_actions
    ADD CONSTRAINT task_send_task_id_foreign FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: tasks_count tasks_count_document_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_count
    ADD CONSTRAINT tasks_count_document_type_id_foreign FOREIGN KEY (document_type_id) REFERENCES public.document_types(id);


--
-- Name: tasks_count tasks_count_internal_doc_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_count
    ADD CONSTRAINT tasks_count_internal_doc_type_id_foreign FOREIGN KEY (internal_doc_type_id) REFERENCES public.internal_doc_types(id);


--
-- Name: tasks_count tasks_count_sender_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_count
    ADD CONSTRAINT tasks_count_sender_department_id_foreign FOREIGN KEY (sender_department_id) REFERENCES public.departments(id);


--
-- Name: tasks_count tasks_count_sender_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_count
    ADD CONSTRAINT tasks_count_sender_user_id_foreign FOREIGN KEY (sender_user_id) REFERENCES public.users(id);


--
-- Name: tasks tasks_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: tasks tasks_deleted_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: tasks tasks_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: tasks tasks_document_resolution_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_document_resolution_id_fk FOREIGN KEY (document_send_id) REFERENCES public.document_send(id);


--
-- Name: tasks tasks_done_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_done_by_foreign FOREIGN KEY (done_by) REFERENCES public.users(id);


--
-- Name: tasks_for_sign tasks_for_sign_action_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_for_sign
    ADD CONSTRAINT tasks_for_sign_action_by_foreign FOREIGN KEY (action_by) REFERENCES public.users(id);


--
-- Name: tasks_for_sign tasks_for_sign_corrector_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_for_sign
    ADD CONSTRAINT tasks_for_sign_corrector_user_id_foreign FOREIGN KEY (corrector_user_id) REFERENCES public.users(id);


--
-- Name: tasks_for_sign tasks_for_sign_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_for_sign
    ADD CONSTRAINT tasks_for_sign_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: tasks_for_sign tasks_for_sign_document_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_for_sign
    ADD CONSTRAINT tasks_for_sign_document_id_foreign FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: tasks_for_sign tasks_for_sign_recipient_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_for_sign
    ADD CONSTRAINT tasks_for_sign_recipient_department_id_foreign FOREIGN KEY (recipient_department_id) REFERENCES public.departments(id);


--
-- Name: tasks_for_sign tasks_for_sign_recipient_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_for_sign
    ADD CONSTRAINT tasks_for_sign_recipient_user_id_foreign FOREIGN KEY (recipient_user_id) REFERENCES public.users(id);


--
-- Name: tasks_for_sign tasks_for_sign_reject_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_for_sign
    ADD CONSTRAINT tasks_for_sign_reject_id_foreign FOREIGN KEY (reject_id) REFERENCES public.reject_for_sign(id);


--
-- Name: tasks_for_sign tasks_for_sign_sender_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_for_sign
    ADD CONSTRAINT tasks_for_sign_sender_department_id_foreign FOREIGN KEY (sender_department_id) REFERENCES public.departments(id);


--
-- Name: tasks_for_sign tasks_for_sign_sender_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_for_sign
    ADD CONSTRAINT tasks_for_sign_sender_user_id_foreign FOREIGN KEY (sender_user_id) REFERENCES public.users(id);


--
-- Name: tasks_for_sign tasks_for_sign_sign_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks_for_sign
    ADD CONSTRAINT tasks_for_sign_sign_id_foreign FOREIGN KEY (sign_id) REFERENCES public.document_send_signature(id);


--
-- Name: tasks tasks_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.tasks(id);


--
-- Name: tasks tasks_sender_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_sender_department_id_foreign FOREIGN KEY (sender_department_id) REFERENCES public.departments(id);


--
-- Name: tasks tasks_sender_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_sender_user_id_foreign FOREIGN KEY (sender_user_id) REFERENCES public.users(id);


--
-- Name: temporary_accepted_tasks temporary_accepted_tasks_task_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.temporary_accepted_tasks
    ADD CONSTRAINT temporary_accepted_tasks_task_id_foreign FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: upper_organizations upper_organizations_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upper_organizations
    ADD CONSTRAINT upper_organizations_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: upper_organizations upper_organizations_curator_department_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upper_organizations
    ADD CONSTRAINT upper_organizations_curator_department_id_foreign FOREIGN KEY (curator_department_id) REFERENCES public.departments(id);


--
-- Name: upper_organizations upper_organizations_curator_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upper_organizations
    ADD CONSTRAINT upper_organizations_curator_user_id_foreign FOREIGN KEY (curator_user_id) REFERENCES public.users(id);


--
-- Name: upper_organizations upper_organizations_updated_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upper_organizations
    ADD CONSTRAINT upper_organizations_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: user_changes user_changes_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_changes
    ADD CONSTRAINT user_changes_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: user_roles user_roles_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users users_block_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_block_id_foreign FOREIGN KEY (block_id) REFERENCES public.building_blocks(id);


--
-- Name: users users_departments_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_departments_id_fk FOREIGN KEY (parent_department_id) REFERENCES public.departments(id);


--
-- Name: watermark_logs watermark_logs_db_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watermark_logs
    ADD CONSTRAINT watermark_logs_db_id_fkey FOREIGN KEY (db_id) REFERENCES public.organizations(id);


--
-- Name: watermark_logs watermark_logs_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watermark_logs
    ADD CONSTRAINT watermark_logs_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.documents(id);


--
-- Name: watermark_logs watermark_logs_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watermark_logs
    ADD CONSTRAINT watermark_logs_file_id_fkey FOREIGN KEY (file_id) REFERENCES public.files(id);


--
-- Name: watermark_logs watermark_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.watermark_logs
    ADD CONSTRAINT watermark_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict 3iT9kp4JV4M2GMZlWRtz7NUhQmj8N6uBruVP3l59v2PkBKc9tMFC1BTl3n60cJi

