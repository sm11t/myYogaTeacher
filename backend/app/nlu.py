"""
Light-weight NLU for teacher prompts → intent JSON.
Rules are explicit, no ML retrain needed.
"""
import re
import spacy
from .schema_ingest import get_schema_metadata

nlp = spacy.load("en_core_web_sm")
SCHEMA = get_schema_metadata()

def _contains_all(text: str, *subs) -> bool:
    lo = text.lower()
    return all(s in lo for s in subs)

def extract_intent(text: str) -> dict:
    lo = text.lower()

    # -------------------------------------------------------------- #
    # 1) first-trial-session (today / next X hours)                  #
    #    Accept “first” **or** “1st”                                 #
    # -------------------------------------------------------------- #
    if re.search(r"(?:first|1st)\s+trial\s+session", lo):
        m_next = re.search(r"(?:within|in)\s+(?:the\s+)?next\s+(\d+)\s*hours?", lo)
        if m_next:
            return {"query_type": "first_trial", "params": {"time": "next_hours", "hours": int(m_next.group(1))}}
        if "today" in lo:
            return {"query_type": "first_trial", "params": {"time": "today"}}
        return {"query_type": "first_trial", "params": {}}

    # -------------------------------------------------------------- #
    # 2) trial(s) expiring                                           #
    # -------------------------------------------------------------- #
    if re.search(r"(?:trial|trials)(?:\s+period)?\b.*?\b(?:expir\w*|ending)", lo):
        today = "today" in lo
        tomorrow = "tomorrow" in lo
        when = (
            "today_tomorrow" if today and tomorrow
            else "today" if today
            else "tomorrow" if tomorrow
            else "soon"
        )
        return {"query_type": "trial_expiring", "params": {"when": when}}

    # -------------------------------------------------------------- #
    # 3) membership but no recent session (past N weeks)             #
    # -------------------------------------------------------------- #
    m_weeks = re.search(
        r"(?:member|membership|taken\s+a\s+membership)"
        r".*(?:not\s+booked.*?session|haven(?:'|’)?t\s+booked.*?session|no\s+session)"
        r".*past\s+(\d+)\s*weeks?",
        lo
    )
    if m_weeks:
        return {"query_type": "member_no_session", "params": {"weeks": int(m_weeks.group(1))}}

    # -------------------------------------------------------------- #
    # 4) never booked any session                                   #
    # -------------------------------------------------------------- #
    if re.search(r"(?:never|not)\s+booked.*session", lo):
        return {"query_type": "never_booked", "params": {}}

    # -------------------------------------------------------------- #
    # 5) trial finished session but no membership                   #
    # -------------------------------------------------------------- #
    if (
        "trial" in lo
        and re.search(r"finished|completed|at least", lo)
        and "session" in lo
        and re.search(r"not\s+taken|no\s+membership|without\s+membership", lo)
    ):
        return {"query_type": "trial_finished_no_membership", "params": {}}

    # -------------------------------------------------------------- #
    # 6) membership renew today                                     #
    # -------------------------------------------------------------- #
    if re.search(r"membership.*renew.*today", lo):
        return {"query_type": "membership_renew_today", "params": {}}

    # -------------------------------------------------------------- #
    # 7) count memberships this week / month                        #
    # -------------------------------------------------------------- #
    if lo.strip().startswith("how many") and "membership" in lo:
        if "this week" in lo:
            return {"query_type": "count_members_period", "params": {"period": "week"}}
        if "this month" in lo:
            return {"query_type": "count_members_period", "params": {"period": "month"}}
        return {"query_type": "count_members_period", "params": {}}

    # -------------------------------------------------------------- #
    # 8) list_students                                              #
    # -------------------------------------------------------------- #
    if re.search(r"\b(my|mine|me|our)\b", lo) and "student" in lo:
        return {"query_type": "list_students", "params": {}}

    # -------------------------------------------------------------- #
    # 9) fallback: simple per-table filter                          #
    # -------------------------------------------------------------- #
    tokens = [t.text for t in nlp(lo)]
    table = next((tbl for tbl in SCHEMA if tbl in tokens or f"{tbl}s" in tokens), "student")
    cols = SCHEMA.get(table, {}).get("columns", [])
    filters = {col: tokens[tokens.index(col) + 1]
               for col in cols if col in tokens and tokens.index(col) + 1 < len(tokens)}

    return {"query_type": "simple_filter", "params": {"table": table, "filters": filters}}
