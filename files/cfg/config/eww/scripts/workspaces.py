#!/usr/bin/env python
import json
import os
import socket
import subprocess
import sys


def get_all_workspaces():
    """Get both active and empty workspaces from Hyprland"""
    try:
        # Get active workspaces
        result = subprocess.run(
            ["hyprctl", "workspaces", "-j"], capture_output=True, text=True, check=True
        )
        active_workspaces = json.loads(result.stdout)

        workspace_info = {}

        # Add active workspaces
        for ws in active_workspaces:
            workspace_id = ws.get("id", 0)
            if isinstance(workspace_id, int):
                workspace_info[workspace_id] = {"active": False, "visible": True}

        # Get current active workspace
        result = subprocess.run(
            ["hyprctl", "activeworkspace", "-j"],
            capture_output=True,
            text=True,
            check=True,
        )
        active_ws = json.loads(result.stdout)
        active_id = active_ws.get("id", 1)

        # Ensure active workspace is in the list even if empty
        if active_id not in workspace_info:
            workspace_info[active_id] = {"active": True, "visible": False}
        else:
            workspace_info[active_id]["active"] = True

        return workspace_info, active_id
    except Exception as e:
        print(f"Error getting workspaces: {e}", file=sys.stderr)
        return {1: {"active": True, "visible": True}}, 1


def format_workspace_text(workspace_info, active_workspace):
    """Format all workspaces into a text string"""
    texts = []

    for ws_id in sorted(workspace_info.keys()):
        if ws_id > 0:
            if ws_id == active_workspace:
                style = "workspace-active"
            elif workspace_info[ws_id]["visible"]:
                style = "workspace-visible"
            else:
                style = "workspace-empty"

            texts.append(f'(label :class "{style}" :text "{ws_id}")')

    return " ".join(texts)


def update_workspace_display(active_workspace, workspace_info):
    """Generate and display the workspace widget"""
    try:
        workspace_text = format_workspace_text(workspace_info, active_workspace)
        prompt = f"(box {workspace_text})"
        subprocess.run(f"echo '{prompt}'", shell=True, check=True)
    except Exception as e:
        print(f"Error updating display: {e}", file=sys.stderr)
        fallback = '(box (label :class "workspace-active" :text "1"))'
        subprocess.run(f"echo '{fallback}'", shell=True)


def main():
    # Get and display initial state
    initial_workspaces, initial_active = get_all_workspaces()
    update_workspace_display(initial_active, initial_workspaces)

    while True:
        try:
            sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            server_address = f"{os.environ.get('XDG_RUNTIME_DIR', '/tmp')}/hypr/{os.environ.get('HYPRLAND_INSTANCE_SIGNATURE', '')}/.socket2.sock"
            sock.connect(server_address)

            while True:
                new_event = sock.recv(4096).decode("utf-8").strip()
                if not new_event:
                    continue

                for item in new_event.split("\n"):
                    try:
                        if "workspace>>" == item[0:11]:
                            try:
                                active_workspace = int(item.split(">>")[1].strip())
                            except (ValueError, IndexError):
                                print(
                                    f"Invalid workspace number: {item}", file=sys.stderr
                                )
                                continue

                            workspace_info, _ = get_all_workspaces()
                            update_workspace_display(active_workspace, workspace_info)

                        elif any(
                            x in item
                            for x in ["createworkspace>>", "destroyworkspace>>"]
                        ):
                            workspace_info, active_workspace = get_all_workspaces()
                            update_workspace_display(active_workspace, workspace_info)
                    except Exception as e:
                        print(f"Error processing event '{item}': {e}", file=sys.stderr)
                        continue

        except (socket.error, ConnectionRefusedError) as e:
            print(f"Socket error: {e}", file=sys.stderr)
            subprocess.run("sleep 1", shell=True)
        except Exception as e:
            print(f"Unexpected error: {e}", file=sys.stderr)
            subprocess.run("sleep 1", shell=True)
        finally:
            try:
                sock.close()
            except:
                pass


if __name__ == "__main__":
    main()
