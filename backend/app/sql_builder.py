"""
Builds SQL from intent.  Each block adds the right teacher filter:
  • session-based queries → se.teacher_id
  • anything else         → JOIN student_concierge sc … AND sc.teacher_id = :teacher_id
"""

def _teacher_filter(col_alias: str, params: dict) -> str:
    """Return teacher filter or empty string."""
    return f"{col_alias} = :teacher_id" if params.get("teacher_id") is not None else ""

def build_sql(intent: dict) -> str:
    qt = intent.get("query_type")
    p   = intent.get("params", {})

    # ------------------------------------------------------------------ #
    # 1) first-trial session (today / next X hours)                      #
    # ------------------------------------------------------------------ #
    if qt == "first_trial":
        where = [
            "se.is_trial = 1",
            "se.is_first_session = TRUE"
        ]
        if p.get("time") == "today":
            where.append("DATE(se.start_time) = CURRENT_DATE")
        elif p.get("time") == "next_hours":
            hrs = int(p.get("hours", 0))
            where.append(
                f"se.start_time BETWEEN NOW() AND NOW() + INTERVAL '{hrs} hours'"
            )
        tf = _teacher_filter("se.teacher_id", p)
        if tf:
            where.append(tf)
        return (
            "SELECT DISTINCT s.* "
            "FROM student  s "
            "JOIN session  se ON se.student_id = s.id "
            f"WHERE {' AND '.join(where)};"
        )

    # ------------------------------------------------------------------ #
    # 2) trial expiring (based on student.trial_end_date)                #
    # ------------------------------------------------------------------ #
    if qt == "trial_expiring":
        when  = p.get("when", "soon")
        where = []
        if when == "today":
            where.append("DATE(s.trial_end_date) = CURRENT_DATE")
        elif when == "tomorrow":
            where.append("DATE(s.trial_end_date) = CURRENT_DATE + INTERVAL '1 day'")
        elif when == "today_tomorrow":
            where.append(
                "DATE(s.trial_end_date) IN "
                "(CURRENT_DATE, CURRENT_DATE + INTERVAL '1 day')"
            )
        else:  # soon  → within 3 days
            where.append(
                "s.trial_end_date BETWEEN CURRENT_DATE "
                "AND CURRENT_DATE + INTERVAL '3 day'"
            )
        tf = _teacher_filter("sc.teacher_id", p)
        if tf:
            where.append(tf)
        return (
            "SELECT DISTINCT s.* "
            "FROM student             s "
            "JOIN student_concierge sc ON sc.student_id = s.id "
            f"WHERE {' AND '.join(where)};"
        )

    # ------------------------------------------------------------------ #
    # 3) never booked any session                                        #
    # ------------------------------------------------------------------ #
    if qt == "never_booked":
        where = [
            "NOT EXISTS (SELECT 1 FROM session se WHERE se.student_id = s.id)"
        ]
        tf = _teacher_filter("sc.teacher_id", p)
        if tf:
            where.append(tf)
        return (
            "SELECT s.* "
            "FROM student             s "
            "JOIN student_concierge sc ON sc.student_id = s.id "
            f"WHERE {' AND '.join(where)};"
        )

    # ------------------------------------------------------------------ #
    # 4) trial active, finished session, no membership                   #
    # ------------------------------------------------------------------ #
    if qt == "trial_finished_no_membership":
        where = [
            "se.is_trial = 1",
            "se.status   = 'FINISHED'",
            "m.id IS NULL"
        ]
        tf = _teacher_filter("se.teacher_id", p)
        if tf:
            where.append(tf)
        return (
            "SELECT DISTINCT s.* "
            "FROM student  s "
            "JOIN session  se ON se.student_id = s.id "
            "LEFT JOIN membership m ON m.student_id = s.id "
            f"WHERE {' AND '.join(where)};"
        )

    # ------------------------------------------------------------------ #
    # 5) membership but no recent session (past N weeks)                 #
    # ------------------------------------------------------------------ #
    if qt == "member_no_session":
        weeks = int(p.get("weeks", 4))
        where = [
            "m.is_active = TRUE",
            "NOT EXISTS ("
            " SELECT 1 FROM session se "
            " WHERE se.student_id = s.id "
            f"   AND se.start_time >= NOW() - INTERVAL '{weeks} weeks')"
        ]
        tf = _teacher_filter("sc.teacher_id", p)
        if tf:
            where.append(tf)
        return (
            "SELECT DISTINCT s.* "
            "FROM student             s "
            "JOIN membership         m  ON m.student_id = s.id "
            "JOIN student_concierge sc ON sc.student_id = s.id "
            f"WHERE {' AND '.join(where)};"
        )

    # ------------------------------------------------------------------ #
    # 6) membership renew today                                          #
    # ------------------------------------------------------------------ #
    if qt == "membership_renew_today":
        where = ["m.next_renewal_date = CURRENT_DATE"]
        tf = _teacher_filter("sc.teacher_id", p)
        if tf:
            where.append(tf)
        return (
            "SELECT s.* "
            "FROM student             s "
            "JOIN membership         m  ON m.student_id = s.id "
            "JOIN student_concierge sc ON sc.student_id = s.id "
            f"WHERE {' AND '.join(where)};"
        )

    # ------------------------------------------------------------------ #
    # 7) count memberships this week / month                             #
    # ------------------------------------------------------------------ #
    if qt == "count_members_period":
        period = p.get("period")
        if period == "week":
            date_clause = (
                "DATE_TRUNC('week', m.start_date) "
                "= DATE_TRUNC('week', CURRENT_DATE)"
            )
        elif period == "month":
            date_clause = (
                "DATE_TRUNC('month', m.start_date) "
                "= DATE_TRUNC('month', CURRENT_DATE)"
            )
        else:
            date_clause = "TRUE"
        where = [date_clause]
        tf = _teacher_filter("sc.teacher_id", p)
        if tf:
            where.append(tf)
        return (
            "SELECT COUNT(*) AS cnt "
            "FROM membership         m "
            "JOIN student            s  ON s.id = m.student_id "
            "JOIN student_concierge  sc ON sc.student_id = s.id "
            f"WHERE {' AND '.join(where)};"
        )

    # ------------------------------------------------------------------ #
    # 8) list_students                                                   #
    # ------------------------------------------------------------------ #
    if qt == "list_students":
        tf = _teacher_filter("sc.teacher_id", p)
        sql = (
            "SELECT s.id, s.first_name, s.last_name "
            "FROM student             s "
            "JOIN student_concierge  sc ON sc.student_id = s.id"
        )
        if tf:
            sql += f" WHERE {tf}"
        sql += " ORDER BY s.last_name;"
        return sql

        # ------------------------------------------------------------------ #
    # 9) simple fallback                                                 #
    # ------------------------------------------------------------------ #
    if qt == "simple_filter":
        tbl     = p.get("table", "student")
        filters = p.get("filters", {})

        where = []
        for col, val in filters.items():
            where.append(
                f"{col} = {val}" if str(val).isdigit()
                else f"LOWER({col}) = LOWER('{val}')"
            )

        tf = _teacher_filter("sc.teacher_id", p)   # teacher filter if supplied
        if tf:
            where.append(tf)

        # base SELECT
        sql = f"SELECT * FROM {tbl}"

        # add concierge join only when teacher_id present
        if tf:
            sql += f" JOIN student_concierge sc ON sc.student_id = {tbl}.id"

        # WHERE clause
        if where:
            sql += " WHERE " + " AND ".join(where)

        return sql + ";"

