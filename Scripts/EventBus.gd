extends Node

# =============================
# EventBus: 프로젝트 전역 이벤트/신호 중계자
# =============================
# 모든 주요 상태 변화, 사용자 액션, 경로 탐색 이벤트 등을 신호로 정의합니다.
# 각 스크립트는 EventBus의 신호만 emit/구독하면 되고, 서로 직접 참조하지 않습니다.
# 오토로드(싱글턴)로 등록해서 사용하세요.

# --- 셀/타일 관련 신호 ---
signal cell_changed(x, y, value) # 셀의 상태가 변경됨 (좌표, 상태값)
signal cell_cost_changed(x, y, cost) # 셀의 가중치가 변경됨 (좌표, 가중치)
signal cell_removed(x, y) # 셀이 삭제됨 (좌표)

# --- 셀/타일 조작 요청 신호 (핸들러용) ---
signal set_cell(x, y, value, cost) # 셀 상태/가중치 설정 요청
signal remove_cell(x, y) # 셀 삭제 요청

# --- 셀/타일 정보 조회 신호 ---
signal request_cell_cost(x, y) # (x, y) 좌표의 cost 값을 요청
signal response_cell_cost(x, y, cost) # (x, y) 좌표의 cost 값 응답

# --- 경로 탐색 관련 신호 ---
signal path_finding_started() # 경로 탐색이 시작됨
signal path_finding_finished(success, path) # 경로 탐색이 끝남 (성공여부, 경로배열)
signal path_drawn(path) # 경로가 그려짐 (경로배열)
signal try_path_find(start, end) # 경로 탐색 요청
signal clear_visited_and_route() # 방문 흔적/경로 초기화 요청
signal path_removed() # 경로 제거 요청

# --- 입력/상호작용 관련 신호 ---
signal input_mode_changed(mode) # 입력 모드가 변경됨 (1: 시작/도착점, 2: 벽, 3: 가중치)
signal vertex_pos_changed(vertex_pos) # 시작/도착점 목록이 변경됨 (배열)

# --- 기타 신호(필요시 확장) ---
signal board_reset() # 보드가 리셋됨
signal board_initialized(max_x, max_y) # 보드가 새로 생성됨
signal path_finding_strategy_changed(strategy) # 경로 탐색 전략 변경됨

# --- has_route 질의/응답 신호 ---
signal request_has_route() # has_route 질의
signal response_has_route(has_route) # has_route 응답

# --- disable_visit 신호 ---
signal disable_visit(x, y) # 방문 해제 요청

# --- 예시: 신호 발신/구독 방법 ---
# EventBus.emit_signal("set_cell", x, y, value, cost)
# EventBus.connect("set_cell", Callable(self, "_on_set_cell")) 
