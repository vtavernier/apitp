SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE admin_users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    super_admin boolean
);


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admin_users_id_seq OWNED BY admin_users.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE assignments (
    id bigint NOT NULL,
    group_id bigint,
    project_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    sent_start_email timestamp without time zone,
    sent_reminder_email timestamp without time zone,
    sent_ended_email timestamp without time zone
);


--
-- Name: assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assignments_id_seq OWNED BY assignments.id;


--
-- Name: group_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE group_memberships (
    id bigint NOT NULL,
    group_id bigint,
    user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: group_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE group_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: group_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE group_memberships_id_seq OWNED BY group_memberships.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE groups (
    id bigint NOT NULL,
    year integer,
    name character varying,
    admin_user_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE projects (
    id bigint NOT NULL,
    year integer,
    name character varying,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    url character varying,
    max_upload_size integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    owner_id integer
);


--
-- Name: project_times; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_times AS
 SELECT projects.id,
    projects.start_time,
    projects.end_time,
    date_trunc('hour'::text, (projects.start_time + (((projects.end_time - projects.start_time) * (6)::double precision) / (7)::double precision))) AS reminder_time
   FROM projects;


--
-- Name: submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE submissions (
    id bigint NOT NULL,
    user_id bigint,
    project_id bigint,
    file character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_submissions; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW user_submissions AS
 SELECT DISTINCT users.id AS user_id,
    users.name AS username,
    users.email,
    assignments.project_id,
    submissions.id AS submission_id
   FROM (((users
     JOIN group_memberships ON ((group_memberships.user_id = users.id)))
     JOIN assignments ON ((assignments.group_id = group_memberships.group_id)))
     LEFT JOIN submissions ON (((submissions.project_id = assignments.project_id) AND (submissions.user_id = users.id))))
  ORDER BY users.name, users.email;


--
-- Name: pending_ended_emails; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW pending_ended_emails AS
 SELECT email_status.project_id,
    email_status.user_id,
    email_status.send_start AS send_at
   FROM ( SELECT assignments.project_id,
            users.id AS user_id,
            project_times.end_time AS send_start,
            (project_times.end_time + '7 days'::interval) AS send_end
           FROM ((((assignments
             JOIN group_memberships ON ((assignments.group_id = group_memberships.group_id)))
             JOIN users ON ((group_memberships.user_id = users.id)))
             JOIN project_times ON ((project_times.id = assignments.project_id)))
             LEFT JOIN user_submissions ON (((user_submissions.user_id = users.id) AND (user_submissions.project_id = assignments.project_id))))
          GROUP BY assignments.project_id, users.id, project_times.end_time, (project_times.end_time + '7 days'::interval)
         HAVING ((count(assignments.sent_ended_email) = 0) AND (count(user_submissions.submission_id) = 0))) email_status
  WHERE ((email_status.send_start <= now()) AND (now() <= email_status.send_end));


--
-- Name: pending_reminder_emails; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW pending_reminder_emails AS
 SELECT email_status.project_id,
    email_status.user_id,
    email_status.send_start AS send_at
   FROM ( SELECT assignments.project_id,
            users.id AS user_id,
            project_times.reminder_time AS send_start,
            project_times.end_time AS send_end
           FROM ((((assignments
             JOIN group_memberships ON ((assignments.group_id = group_memberships.group_id)))
             JOIN users ON ((group_memberships.user_id = users.id)))
             JOIN project_times ON ((project_times.id = assignments.project_id)))
             LEFT JOIN user_submissions ON (((user_submissions.user_id = users.id) AND (user_submissions.project_id = assignments.project_id))))
          GROUP BY assignments.project_id, users.id, project_times.reminder_time, project_times.end_time
         HAVING ((count(assignments.sent_reminder_email) = 0) AND (count(user_submissions.submission_id) = 0))) email_status
  WHERE ((email_status.send_start <= now()) AND (now() <= email_status.send_end));


--
-- Name: pending_start_emails; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW pending_start_emails AS
 SELECT email_status.project_id,
    email_status.user_id,
    email_status.send_start AS send_at
   FROM ( SELECT assignments.project_id,
            users.id AS user_id,
            project_times.start_time AS send_start,
            project_times.reminder_time AS send_end
           FROM (((assignments
             JOIN group_memberships ON ((assignments.group_id = group_memberships.group_id)))
             JOIN users ON ((group_memberships.user_id = users.id)))
             JOIN project_times ON ((project_times.id = assignments.project_id)))
          GROUP BY assignments.project_id, users.id, project_times.start_time, project_times.reminder_time
         HAVING (count(assignments.sent_start_email) = 0)) email_status
  WHERE ((email_status.send_start <= now()) AND (now() <= email_status.send_end));


--
-- Name: project_events; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_events AS
 SELECT events.id,
    events.next_event
   FROM ( SELECT project_times.id,
            LEAST(
                CASE
                    WHEN (project_times.start_time < now()) THEN NULL::timestamp without time zone
                    ELSE project_times.start_time
                END,
                CASE
                    WHEN (project_times.reminder_time < now()) THEN NULL::timestamp without time zone
                    ELSE project_times.reminder_time
                END,
                CASE
                    WHEN (project_times.end_time < now()) THEN NULL::timestamp without time zone
                    ELSE project_times.end_time
                END) AS next_event
           FROM project_times) events
  WHERE (events.next_event IS NOT NULL)
  ORDER BY events.next_event;


--
-- Name: project_statistics; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW project_statistics AS
 SELECT user_submissions.project_id,
    count(user_submissions.submission_id) AS submission_count,
    count(*) AS user_count
   FROM user_submissions
  GROUP BY user_submissions.project_id;


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;


--
-- Name: que_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE que_jobs (
    priority smallint DEFAULT 100 NOT NULL,
    run_at timestamp with time zone DEFAULT now() NOT NULL,
    job_id bigint NOT NULL,
    job_class text NOT NULL,
    args json DEFAULT '[]'::json NOT NULL,
    error_count integer DEFAULT 0 NOT NULL,
    last_error text,
    queue text DEFAULT ''::text NOT NULL
);


--
-- Name: TABLE que_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE que_jobs IS '3';


--
-- Name: que_jobs_job_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE que_jobs_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: que_jobs_job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE que_jobs_job_id_seq OWNED BY que_jobs.job_id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE submissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE submissions_id_seq OWNED BY submissions.id;


--
-- Name: user_projects; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW user_projects AS
 SELECT DISTINCT projects.id,
    projects.year,
    projects.name,
    projects.start_time,
    projects.end_time,
    projects.url,
    projects.max_upload_size,
    projects.created_at,
    projects.updated_at,
    submissions.id AS submission_id,
    users.id AS user_id
   FROM ((((users
     JOIN group_memberships ON ((group_memberships.user_id = users.id)))
     JOIN assignments ON ((assignments.group_id = group_memberships.group_id)))
     JOIN projects ON ((projects.id = assignments.project_id)))
     LEFT JOIN submissions ON (((submissions.project_id = projects.id) AND (submissions.user_id = users.id))));


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: admin_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_users ALTER COLUMN id SET DEFAULT nextval('admin_users_id_seq'::regclass);


--
-- Name: assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments ALTER COLUMN id SET DEFAULT nextval('assignments_id_seq'::regclass);


--
-- Name: group_memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_memberships ALTER COLUMN id SET DEFAULT nextval('group_memberships_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: que_jobs job_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY que_jobs ALTER COLUMN job_id SET DEFAULT nextval('que_jobs_job_id_seq'::regclass);


--
-- Name: submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY submissions ALTER COLUMN id SET DEFAULT nextval('submissions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: assignments assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: group_memberships group_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_memberships
    ADD CONSTRAINT group_memberships_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: que_jobs que_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY que_jobs
    ADD CONSTRAINT que_jobs_pkey PRIMARY KEY (queue, priority, run_at, job_id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: submissions submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY submissions
    ADD CONSTRAINT submissions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_email ON admin_users USING btree (email);


--
-- Name: index_admin_users_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_name ON admin_users USING btree (name);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON admin_users USING btree (reset_password_token);


--
-- Name: index_assignments_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assignments_on_group_id ON assignments USING btree (group_id);


--
-- Name: index_assignments_on_group_id_and_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_assignments_on_group_id_and_project_id ON assignments USING btree (group_id, project_id);


--
-- Name: index_assignments_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assignments_on_project_id ON assignments USING btree (project_id);


--
-- Name: index_group_memberships_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_memberships_on_group_id ON group_memberships USING btree (group_id);


--
-- Name: index_group_memberships_on_group_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_group_memberships_on_group_id_and_user_id ON group_memberships USING btree (group_id, user_id);


--
-- Name: index_group_memberships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_group_memberships_on_user_id ON group_memberships USING btree (user_id);


--
-- Name: index_groups_on_admin_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_admin_user_id ON groups USING btree (admin_user_id);


--
-- Name: index_groups_on_year_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_groups_on_year_and_name ON groups USING btree (year, name);


--
-- Name: index_submissions_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_submissions_on_project_id ON submissions USING btree (project_id);


--
-- Name: index_submissions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_submissions_on_user_id ON submissions USING btree (user_id);


--
-- Name: index_submissions_on_user_id_and_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_submissions_on_user_id_and_project_id ON submissions USING btree (user_id, project_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_name ON users USING btree (name);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: group_memberships fk_rails_14271168a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_memberships
    ADD CONSTRAINT fk_rails_14271168a1 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: projects fk_rails_219ef9bf7d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY projects
    ADD CONSTRAINT fk_rails_219ef9bf7d FOREIGN KEY (owner_id) REFERENCES admin_users(id);


--
-- Name: assignments fk_rails_21b0a6eb0c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments
    ADD CONSTRAINT fk_rails_21b0a6eb0c FOREIGN KEY (group_id) REFERENCES groups(id);


--
-- Name: assignments fk_rails_4d3d2c839c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments
    ADD CONSTRAINT fk_rails_4d3d2c839c FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: submissions fk_rails_8d85741475; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY submissions
    ADD CONSTRAINT fk_rails_8d85741475 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: submissions fk_rails_9099815ed5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY submissions
    ADD CONSTRAINT fk_rails_9099815ed5 FOREIGN KEY (project_id) REFERENCES projects(id);


--
-- Name: group_memberships fk_rails_d05778f88b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_memberships
    ADD CONSTRAINT fk_rails_d05778f88b FOREIGN KEY (group_id) REFERENCES groups(id);


--
-- Name: groups fk_rails_eab7502ed7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT fk_rails_eab7502ed7 FOREIGN KEY (admin_user_id) REFERENCES admin_users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20170921115756'),
('20170921145222'),
('20170921150036'),
('20170921150740'),
('20170921150956'),
('20170921151909'),
('20170921152344'),
('20170922130442'),
('20170922143400'),
('20170922182522'),
('20170923173030'),
('20170923180227'),
('20170923182803'),
('20170924110311'),
('20170924122541'),
('20170924175248'),
('20170924180557');


