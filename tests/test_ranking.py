import os
import types
import pytest

import sys
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

import db
import app as app_module

app = app_module.app
cache = app_module.cache
RANKING_CACHE_KEY = app_module.RANKING_CACHE_KEY

class DummyCursor:
    def __init__(self, fetchone_results=None, fetchall_results=None):
        self.queries = []
        self.execute_count = 0
        self.fetchone_results = fetchone_results if fetchone_results is not None else [
            {"total": 1},  # total_asignados
            {"total": 1},  # total_respuestas
        ]
        self.fetchall_results = fetchall_results if fetchall_results is not None else [
            [],  # incompletas_rows
            [{"nombre": "Factor X", "total": 5}],  # ranking
        ]

    def execute(self, query, params=None):
        self.execute_count += 1
        self.queries.append((query, params))

    def executemany(self, query, seq_params):
        self.queries.append((query, seq_params))

    def fetchone(self):
        return self.fetchone_results.pop(0)

    def fetchall(self):
        return self.fetchall_results.pop(0)

    def close(self):
        pass

    def reset(self):
        self.queries = []
        self.execute_count = 0

class DummyConnection:
    def __init__(self, cursor):
        self._cursor = cursor

    def cursor(self, dictionary=True):
        return self._cursor

    def commit(self):
        pass

    def close(self):
        pass


def test_vista_ranking_parametrized(monkeypatch):
    cursor = DummyCursor()
    conn = DummyConnection(cursor)
    monkeypatch.setattr(db, "get_connection", lambda: conn)
    monkeypatch.setattr(app_module, "get_connection", lambda: conn)

    # reset cache
    cache.delete(RANKING_CACHE_KEY)

    with app.test_client() as client:
        with client.session_transaction() as sess:
            sess["is_admin"] = True
        resp = client.get("/admin/ranking")
        assert resp.status_code == 200
        assert b"Factor X" in resp.data

    # verify queries used placeholders
    # queries: total_asignados, total_respuestas, incompletas, ranking
    incompletas_query, incompletas_params = cursor.queries[2]
    ranking_query, ranking_params = cursor.queries[3]
    assert "HAVING COUNT(p.id_factor) < %s" in incompletas_query
    assert incompletas_params == (10,)
    assert "JOIN (" in ranking_query
    assert "HAVING COUNT(id_factor) = %s" in ranking_query
    assert ranking_params == (10,)


def test_vista_ranking_incompletas(monkeypatch):
    cursor = DummyCursor(
        fetchone_results=[
            {"total": 1},  # total_asignados
            {"total": 1},  # total_respuestas
        ],
        fetchall_results=[
            [{"id_respuesta": 42}],  # incompletas_rows
            [{"nombre": "Factor X", "total": 5}],  # ranking
        ],
    )
    conn = DummyConnection(cursor)
    monkeypatch.setattr(db, "get_connection", lambda: conn)
    monkeypatch.setattr(app_module, "get_connection", lambda: conn)

    cache.delete(RANKING_CACHE_KEY)

    with app.test_client() as client:
        with client.session_transaction() as sess:
            sess["is_admin"] = True
        resp = client.get("/admin/ranking")
        assert resp.status_code == 200
        assert b"Factor X" in resp.data
        assert b"ID: 42" in resp.data


def test_ranking_cache_invalidation_after_ponderacion(monkeypatch):
    fetchone_results = [
        {"total": 1}, {"total": 1},
        {"total": 1}, {"total": 1},
        {"total": 1}, {"total": 1},
    ]
    fetchall_results = [
        [], [{"nombre": "Factor X", "total": 5}],
        [], [{"nombre": "Factor X", "total": 5}],
    ]
    cursor = DummyCursor(fetchone_results=fetchone_results, fetchall_results=fetchall_results)
    conn = DummyConnection(cursor)
    monkeypatch.setattr(db, "get_connection", lambda: conn)
    monkeypatch.setattr(app_module, "get_connection", lambda: conn)

    cache.delete(RANKING_CACHE_KEY)

    with app.test_client() as client:
        with client.session_transaction() as sess:
            sess["is_admin"] = True

        cursor.reset()
        resp = client.get("/admin/ranking")
        assert resp.status_code == 200
        assert cursor.execute_count == 4

        cursor.reset()
        resp = client.get("/admin/ranking")
        assert resp.status_code == 200
        assert cursor.execute_count == 2

        cursor.reset()
        resp = client.post("/admin/ponderar", data={"id_respuesta": "1", "ponderacion_1": "1"})
        assert resp.status_code == 302

        cursor.reset()
        resp = client.get("/admin/ranking")
        assert resp.status_code == 200
        assert cursor.execute_count == 4
