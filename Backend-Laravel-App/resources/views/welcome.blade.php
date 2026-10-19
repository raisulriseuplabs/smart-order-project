<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <meta name="app-name" content="{{ config('app.name', 'Laravel') }}">
    <title>FTP Drive — {{ config('app.name', 'Laravel') }}</title>
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=outfit:400,500,600,700|jetbrains-mono:400,500" rel="stylesheet">
    <style>
        :root {
            --bg: #070b14;
            --ink: #e8eefc;
            --muted: #93a0bd;
            --line: rgba(154, 196, 255, .16);
            --cyan: #79f0ff;
            --violet: #b7a6ff;
            --danger: #ff6d8f;
            --panel: rgba(10, 16, 32, .78);
            --ok: #8ef0c2;
            color-scheme: dark;
        }

        * { box-sizing: border-box; }
        html, body { height: 100%; }
        body {
            margin: 0;
            color: var(--ink);
            font-family: Outfit, ui-sans-serif, system-ui, sans-serif;
            background:
                radial-gradient(900px 480px at 10% -10%, rgba(121, 240, 255, .16), transparent 55%),
                radial-gradient(800px 500px at 110% 0%, rgba(183, 166, 255, .18), transparent 50%),
                var(--bg);
        }
        button, input, textarea { font: inherit; color: inherit; }
        button { cursor: pointer; }
        [v-cloak] { display: none; }
        .icon { width: 18px; height: 18px; flex: none; }
        .icon.spin { animation: spin .8s linear infinite; }
        .directory .icon, .icon.directory { color: var(--cyan); }
        .file .icon, .icon.file { color: var(--violet); }
        @keyframes spin { to { transform: rotate(360deg); } }
        @keyframes rise { from { opacity: 0; transform: translateY(8px); } to { opacity: 1; transform: none; } }

        .gate {
            min-height: 100dvh;
            display: grid;
            place-items: center;
            padding: 24px;
        }
        .gate-card {
            width: min(560px, 100%);
            padding: 32px 28px;
            border: 1px solid var(--line);
            border-radius: 28px;
            background: linear-gradient(180deg, rgba(18, 28, 52, .9), rgba(8, 12, 24, .88));
            box-shadow: 0 30px 80px rgba(0, 0, 0, .35), inset 0 1px 0 rgba(255, 255, 255, .06);
            animation: rise .45s ease;
        }
        .eyebrow {
            margin: 0 0 8px;
            color: var(--cyan);
            letter-spacing: .18em;
            font-size: 12px;
            font-weight: 600;
        }
        h1 { margin: 0; font-size: clamp(36px, 6vw, 56px); line-height: .95; }
        .lede { color: var(--muted); font-size: 16px; line-height: 1.55; }
        .mono { font-family: "JetBrains Mono", ui-monospace, monospace; }
        .alert {
            margin: 0 0 16px;
            padding: 12px 14px;
            border-radius: 14px;
            background: rgba(255, 109, 143, .1);
            border: 1px solid rgba(255, 109, 143, .45);
            color: #ffd0db;
        }
        .actions { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 8px; }
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            min-height: 40px;
            padding: 0 14px;
            border-radius: 999px;
            border: 1px solid var(--line);
            background: rgba(255, 255, 255, .04);
            transition: border-color .15s ease, background .15s ease, transform .15s ease;
        }
        .btn:hover { border-color: rgba(121, 240, 255, .55); background: rgba(121, 240, 255, .08); }
        .btn:focus-visible, .icon-btn:focus-visible, .entry:focus-visible, .tree-label:focus-visible, .crumb:focus-visible {
            outline: 2px solid var(--cyan);
            outline-offset: 2px;
        }
        .btn.primary {
            border-color: transparent;
            color: #041018;
            background: linear-gradient(90deg, var(--cyan), #b7f7ff 40%, var(--violet));
            font-weight: 700;
        }
        .btn.danger { color: #ffd5df; border-color: rgba(255, 109, 143, .45); }
        .btn:disabled { opacity: .55; cursor: progress; }
        .chips { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 22px; }
        .chip {
            padding: 6px 10px;
            border-radius: 999px;
            color: var(--muted);
            border: 1px solid var(--line);
            font-size: 13px;
        }

        .shell { height: 100dvh; display: flex; flex-direction: column; }
        .topbar, .toolbar, .crumbs {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .topbar {
            min-height: 68px;
            padding: 12px 16px;
            border-bottom: 1px solid var(--line);
            backdrop-filter: blur(16px);
        }
        .brand { display: flex; align-items: center; gap: 10px; min-width: 180px; }
        .mark {
            width: 36px; height: 36px; border-radius: 12px;
            display: grid; place-items: center;
            color: #041018; font-weight: 800;
            background: linear-gradient(135deg, var(--cyan), var(--violet));
        }
        .brand strong { display: block; }
        .brand small, .muted { color: var(--muted); }
        .search { flex: 1; position: relative; min-width: 140px; }
        .search .icon { position: absolute; left: 12px; top: 11px; color: var(--muted); }
        .search input, .field input, .field textarea {
            width: 100%;
            border: 1px solid var(--line);
            background: rgba(255, 255, 255, .04);
            border-radius: 12px;
        }
        .search input { height: 40px; padding: 0 12px 0 38px; }
        .host {
            padding: 6px 10px;
            border-radius: 999px;
            border: 1px solid rgba(121, 240, 255, .35);
            color: var(--cyan);
            font-size: 12px;
        }
        .workspace {
            flex: 1;
            min-height: 0;
            display: grid;
            grid-template-columns: 280px minmax(0, 1fr) 300px;
        }
        .sidebar, .inspector {
            min-height: 0;
            overflow: auto;
            background: rgba(6, 10, 20, .55);
        }
        .sidebar { border-right: 1px solid var(--line); padding: 14px 10px 24px; }
        .inspector { border-left: 1px solid var(--line); padding: 16px; }
        .side-label {
            margin: 4px 8px 10px;
            color: var(--muted);
            font-size: 12px;
            letter-spacing: .14em;
            text-transform: uppercase;
        }
        .tree-list { list-style: none; margin: 0; padding: 0; }
        .tree-row { display: flex; align-items: center; gap: 2px; padding-left: calc(8px + var(--depth) * 14px); }
        .tree-label, .chevron, .crumb, .entry, .icon-btn {
            border: 0;
            background: transparent;
        }
        .chevron, .icon-btn {
            width: 26px; height: 26px; border-radius: 8px;
            display: grid; place-items: center; color: var(--muted);
        }
        .chevron.ghost { visibility: hidden; }
        .tree-label {
            flex: 1;
            min-width: 0;
            display: flex;
            align-items: center;
            gap: 8px;
            text-align: left;
            padding: 6px 8px;
            border-radius: 10px;
        }
        .tree-label span { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .tree-row.active .tree-label, .tree-label:hover { background: rgba(121, 240, 255, .08); }
        .tree-empty { margin: 0 0 6px 36px; color: var(--muted); font-size: 12px; }
        .stage { min-width: 0; min-height: 0; display: flex; flex-direction: column; position: relative; }
        .toolbar, .crumbs { padding: 12px 16px 0; flex-wrap: wrap; }
        .crumbs { padding-bottom: 8px; }
        .cluster { display: flex; flex-wrap: wrap; gap: 8px; }
        .crumb { color: var(--muted); padding: 0; }
        .crumb:hover, .crumb.current { color: var(--ink); }
        .sep { color: var(--muted); }
        .canvas { flex: 1; min-height: 0; overflow: auto; padding: 8px 16px 28px; }
        .cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(168px, 1fr)); gap: 12px; }
        .entry {
            width: 100%;
            text-align: left;
            border: 1px solid var(--line);
            border-radius: 16px;
            background: rgba(255, 255, 255, .03);
        }
        .entry.grid { display: flex; flex-direction: column; gap: 10px; min-height: 138px; padding: 14px; }
        .entry.grid .icon { width: 28px; height: 28px; }
        .entry.list {
            display: grid;
            grid-template-columns: 28px minmax(0, 1fr) 88px 168px;
            gap: 12px;
            align-items: center;
            min-height: 52px;
            padding: 8px 12px;
            border-radius: 12px;
        }
        .list-head {
            display: grid;
            grid-template-columns: 28px minmax(0, 1fr) 88px 168px;
            gap: 12px;
            padding: 0 12px 8px;
            color: var(--muted);
            font-size: 12px;
            letter-spacing: .08em;
            text-transform: uppercase;
        }
        .entry-name { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-weight: 600; }
        .entry-meta { color: var(--muted); font-size: 13px; }
        .entry:hover, .entry.selected {
            border-color: rgba(121, 240, 255, .55);
            box-shadow: 0 0 0 1px rgba(121, 240, 255, .18);
        }
        .empty {
            margin: 48px auto;
            max-width: 360px;
            text-align: center;
            color: var(--muted);
        }
        .drop {
            position: absolute;
            inset: 12px;
            display: grid;
            place-items: center;
            border: 1.5px dashed var(--cyan);
            border-radius: 20px;
            background: rgba(7, 16, 32, .88);
            color: var(--cyan);
            font-weight: 600;
            z-index: 5;
        }
        .page-loader {
            position: fixed;
            inset: 0;
            z-index: 80;
            display: grid;
            place-items: center;
            background: rgba(7, 11, 20, .5);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
        }
        .page-loader-card {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 16px 22px;
            border-radius: 18px;
            border: 1px solid rgba(255, 255, 255, .22);
            background: rgba(16, 24, 43, .5);
            box-shadow: 0 20px 60px rgba(0, 0, 0, .28), inset 0 1px 0 rgba(255, 255, 255, .18);
            backdrop-filter: blur(18px);
            -webkit-backdrop-filter: blur(18px);
        }
        .page-loader .icon { width: 22px; height: 22px; color: var(--cyan); }
        .preview {
            width: 100%;
            max-height: 180px;
            object-fit: contain;
            border-radius: 12px;
            background: rgba(255, 255, 255, .04);
            margin-bottom: 12px;
        }
        .meta { display: grid; gap: 10px; margin: 14px 0; }
        .meta div { display: flex; justify-content: space-between; gap: 12px; font-size: 14px; }
        .meta dt { color: var(--muted); }
        .meta dd { margin: 0; text-align: right; overflow-wrap: anywhere; }
        .inspector .cluster { margin-top: 8px; }
        .menu-button, .details-button { display: none; }
        .scrim { display: none; }
        .sr-only {
            position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px;
            overflow: hidden; clip: rect(0, 0, 0, 0); border: 0;
        }
        .modal-backdrop {
            position: fixed; inset: 0; z-index: 60;
            display: grid; place-items: center;
            padding: 16px;
            background: rgba(3, 6, 14, .72);
        }
        .modal {
            width: min(520px, 100%);
            padding: 20px;
            border-radius: 22px;
            border: 1px solid var(--line);
            background: #10182b;
            box-shadow: 0 24px 80px rgba(0, 0, 0, .45);
        }
        .modal.wide { width: min(860px, 100%); }
        .modal h2 { margin: 0 0 8px; font-size: 22px; }
        .field { display: grid; gap: 6px; margin: 14px 0; }
        .field span { color: var(--muted); font-size: 13px; }
        .field input, .field textarea { padding: 10px 12px; }
        .field textarea { min-height: 320px; resize: vertical; font-family: "JetBrains Mono", ui-monospace, monospace; font-size: 13px; line-height: 1.5; }
        .modal-actions { display: flex; justify-content: flex-end; gap: 8px; }
        .toasts {
            position: fixed; right: 16px; bottom: 16px; z-index: 70;
            display: flex; flex-direction: column; gap: 8px;
            width: min(360px, calc(100vw - 32px));
        }
        .toast {
            padding: 12px 14px;
            border-radius: 14px;
            border: 1px solid var(--line);
            background: #121a2e;
            box-shadow: 0 10px 30px rgba(0, 0, 0, .3);
        }
        .toast.error { border-color: rgba(255, 109, 143, .6); }
        .view-toggle { margin-left: auto; display: flex; gap: 4px; }

        @media (max-width: 1100px) {
            .workspace { grid-template-columns: 260px minmax(0, 1fr); }
            .inspector {
                display: none;
                position: fixed;
                z-index: 45;
                right: 12px; bottom: 12px; left: 12px;
                max-height: min(70vh, 520px);
                border: 1px solid var(--line);
                border-radius: 20px;
                background: #10182b;
            }
            .inspector.visible { display: block; }
            .details-button { display: inline-flex; }
        }
        @media (max-width: 899px) {
            .workspace { grid-template-columns: 1fr; }
            .menu-button { display: inline-flex; }
            .sidebar {
                position: fixed;
                z-index: 50;
                top: 0; bottom: 0; left: 0;
                width: min(320px, 88vw);
                transform: translateX(-105%);
                transition: transform .2s ease;
                background: #0c1324;
            }
            .sidebar.open { transform: none; }
            .scrim {
                display: block;
                position: fixed; inset: 0; z-index: 40;
                border: 0; background: rgba(0, 0, 0, .5);
            }
            .brand small { display: none; }
            .entry.list, .list-head { grid-template-columns: 28px minmax(0, 1fr) 72px; }
            .hide-sm { display: none !important; }
        }
        @media (prefers-reduced-motion: reduce) {
            *, *::before, *::after { animation: none !important; transition: none !important; }
        }
    </style>
</head>
<body>
@verbatim
<div id="ftp-app" v-cloak>
    <section v-if="!connected" class="gate">
        <div class="gate-card">
            <p class="eyebrow">Remote volume</p>
            <h1>FTP Drive</h1>
            <p class="lede" v-if="configured && host">Connect to <strong class="mono">{{ host }}:{{ port }}</strong>. The password stays in <span class="mono">.env</span> and is never sent to the browser.</p>
            <p class="lede" v-else>Add <span class="mono">FTP_HOST</span>, <span class="mono">FTP_USERNAME</span>, and <span class="mono">FTP_PASSWORD</span> to <span class="mono">.env</span>, then reload this page.</p>
            <p v-if="gateError" class="alert" role="alert">{{ gateError }}</p>
            <div class="actions">
                <button class="btn primary" type="button" :disabled="busy" @click="connect">
                    <icon name="plug"></icon>
                    {{ busy ? 'Connecting…' : 'Connect' }}
                </button>
            </div>
            <div class="chips">
                <span class="chip">Browse folders</span>
                <span class="chip">Upload files</span>
                <span class="chip">Edit text</span>
                <span class="chip">Up to {{ formatSize(maxUpload) }} each</span>
            </div>
        </div>
    </section>

    <div v-else class="shell">
        <header class="topbar">
            <button class="btn menu-button" type="button" @click="sidebarOpen = true" aria-label="Open folders">
                <icon name="menu"></icon>
            </button>
            <div class="brand">
                <div class="mark">F</div>
                <div>
                    <strong>FTP Drive</strong>
                    <small>{{ appName }}</small>
                </div>
            </div>
            <label class="search">
                <icon name="search"></icon>
                <input v-model="query" type="search" placeholder="Search this folder" aria-label="Search this folder">
            </label>
            <span class="host mono" v-if="host">{{ host }}:{{ port }}</span>
            <button class="btn" type="button" @click="disconnect">
                <icon name="unplug"></icon>
                Disconnect
            </button>
        </header>

        <div class="workspace">
            <button v-if="sidebarOpen" class="scrim" type="button" aria-label="Close folders" @click="sidebarOpen = false"></button>
            <aside class="sidebar" :class="{ open: sidebarOpen }">
                <p class="side-label">Folders</p>
                <ul class="tree-list">
                    <tree-node :node="tree" :depth="0" :current="path" :selected="selectedPath" @toggle="toggleNode" @open="openNode"></tree-node>
                </ul>
            </aside>

            <section class="stage" @dragenter="onDragEnter" @dragover="onDragOver" @dragleave="onDragLeave" @drop="onDrop">
                <div v-if="dragging" class="drop">Drop files or folders to upload</div>
                <div class="toolbar">
                    <div class="cluster">
                        <button class="btn" type="button" @click="askFolder"><icon name="folder"></icon> New folder</button>
                        <button class="btn" type="button" @click="startCreateFile"><icon name="file"></icon> New file</button>
                        <button class="btn" type="button" @click="pickFiles"><icon name="upload"></icon> Upload</button>
                        <button class="btn" type="button" @click="pickFolder"><icon name="folder"></icon> Upload folder</button>
                    </div>
                    <div class="cluster" v-if="selected">
                        <button class="btn" type="button" @click="openEntry(selected)">Open</button>
                        <button v-if="selected.type === 'file'" class="btn" type="button" @click="edit(selected)">Edit</button>
                        <button v-if="selected.type === 'file'" class="btn" type="button" @click="download(selected)">Download</button>
                        <button class="btn" type="button" @click="askRename">Rename</button>
                        <button class="btn danger" type="button" @click="askDelete">Delete</button>
                    </div>
                    <div class="view-toggle">
                        <button class="btn details-button" type="button" @click="detailsOpen = !detailsOpen">Details</button>
                        <button class="icon-btn" type="button" :aria-pressed="view === 'grid'" aria-label="Grid view" @click="setView('grid')"><icon name="grid"></icon></button>
                        <button class="icon-btn" type="button" :aria-pressed="view === 'list'" aria-label="List view" @click="setView('list')"><icon name="list"></icon></button>
                    </div>
                </div>
                <nav class="crumbs" aria-label="Folder path">
                    <template v-for="(crumb, index) in crumbs" :key="crumb.path">
                        <span v-if="index" class="sep">/</span>
                        <button class="crumb" :class="{ current: crumb.path === path }" type="button" @click="openDirectory(crumb.path)">{{ crumb.name }}</button>
                    </template>
                </nav>
                <div class="canvas">
                    <div v-if="view === 'list' && visibleEntries.length" class="list-head">
                        <span></span><span>Name</span><span>Size</span><span class="hide-sm">Modified</span>
                    </div>
                    <div :class="view === 'grid' ? 'cards' : 'rows'">
                        <button
                            v-for="entry in visibleEntries"
                            :key="entry.path"
                            class="entry"
                            :class="[view, entry.type, { selected: selected && selected.path === entry.path }]"
                            type="button"
                            @click="select(entry)"
                            @dblclick="openEntry(entry)"
                        >
                            <icon :name="entry.type === 'directory' ? 'folder' : 'file'" :class="entry.type"></icon>
                            <span class="entry-name">{{ entry.name }}</span>
                            <span class="entry-meta">{{ entry.type === 'directory' ? 'Folder' : formatSize(entry.size) }}</span>
                            <span class="entry-meta hide-sm">{{ formatDate(entry.modified) }}</span>
                        </button>
                    </div>
                    <div v-if="!visibleEntries.length" class="empty">
                        <h2>{{ query ? 'Nothing matches' : 'This folder is empty' }}</h2>
                        <p>{{ query ? 'Try another name in this folder.' : 'Create a folder, upload files, or drop them here.' }}</p>
                    </div>
                </div>
                <input ref="fileInput" class="sr-only" type="file" multiple @change="onFileInput($event, false)">
                <input ref="folderInput" class="sr-only" type="file" multiple webkitdirectory directory @change="onFileInput($event, true)">
            </section>

            <aside class="inspector" :class="{ visible: detailsOpen }">
                <p class="side-label">Details</p>
                <div v-if="!selected" class="empty">
                    <p>Select a file or folder. Enter opens it. Delete removes it.</p>
                </div>
                <div v-else>
                    <img v-if="previewUrl" class="preview" :src="previewUrl" :alt="selected.name">
                    <h2 class="entry-name">{{ selected.name }}</h2>
                    <dl class="meta">
                        <div><dt>Type</dt><dd>{{ selected.type === 'directory' ? 'Folder' : 'File' }}</dd></div>
                        <div><dt>Size</dt><dd>{{ selected.type === 'directory' ? '—' : formatSize(selected.size) }}</dd></div>
                        <div><dt>Modified</dt><dd>{{ formatDate(selected.modified) }}</dd></div>
                        <div><dt>Path</dt><dd class="mono">{{ selected.path }}</dd></div>
                    </dl>
                    <div class="cluster">
                        <button class="btn" type="button" @click="openEntry(selected)">Open</button>
                        <button v-if="selected.type === 'file'" class="btn" type="button" @click="download(selected)">Download</button>
                        <button class="btn danger" type="button" @click="askDelete">Delete</button>
                    </div>
                </div>
            </aside>
        </div>
    </div>

    <div v-if="dialog" class="modal-backdrop" @click.self="closeDialog">
        <form class="modal" :class="{ wide: dialog === 'editor' }" role="dialog" aria-modal="true" @submit.prevent="submitDialog">
            <h2>{{ dialogTitle }}</h2>
            <p class="muted" v-if="dialog === 'delete' && selected && selected.type === 'directory'">This deletes the folder and everything inside it.</p>
            <label v-if="dialog === 'folder' || dialog === 'rename' || (dialog === 'editor' && editorMode === 'create')" class="field">
                <span>Name</span>
                <input ref="dialogInput" v-model="draftName" required maxlength="255" autocomplete="off">
            </label>
            <label v-if="dialog === 'editor'" class="field">
                <span>Contents</span>
                <textarea ref="editorInput" v-model="draftContent" spellcheck="false"></textarea>
            </label>
            <div class="modal-actions">
                <button class="btn" type="button" @click="closeDialog">Cancel</button>
                <button class="btn" :class="dialog === 'delete' ? 'danger' : 'primary'" type="submit" :disabled="saving">
                    {{ saving ? 'Working…' : dialogAction }}
                </button>
            </div>
        </form>
    </div>

    <div v-if="busy || saving" class="page-loader" role="status" aria-live="polite" aria-label="Loading">
        <div class="page-loader-card">
            <icon name="spin"></icon>
            <span>{{ busy && !connected ? 'Connecting…' : 'Working…' }}</span>
        </div>
    </div>

    <div class="toasts" aria-live="polite">
        <div v-for="item in toasts" :key="item.id" class="toast" :class="item.tone">{{ item.message }}</div>
    </div>
</div>

<script type="text/x-template" id="tree-node-template">
    <li class="tree-item">
        <div class="tree-row" :class="{ active: node.path === current || node.path === selected }" :style="{ '--depth': depth }">
            <button v-if="node.type === 'directory'" class="chevron" type="button" @click="$emit('toggle', node)" :aria-label="node.open ? 'Collapse folder' : 'Expand folder'">
                <icon :name="node.loading ? 'spin' : (node.open ? 'down' : 'right')"></icon>
            </button>
            <span v-else class="chevron ghost"></span>
            <button class="tree-label" type="button" @click="$emit('open', node)">
                <icon :name="node.type === 'directory' ? 'folder' : 'file'" :class="node.type"></icon>
                <span>{{ node.name }}</span>
            </button>
        </div>
        <p v-if="node.type === 'directory' && node.open && node.loaded && !node.children.length" class="tree-empty">Empty</p>
        <ul v-if="node.type === 'directory' && node.open && node.children.length" class="tree-list">
            <tree-node v-for="child in node.children" :key="child.path" :node="child" :depth="depth + 1" :current="current" :selected="selected" @toggle="$emit('toggle', $event)" @open="$emit('open', $event)"></tree-node>
        </ul>
    </li>
</script>
@endverbatim

<script src="{{ asset('vendor/vue.global.prod.js') }}"></script>
<script>
const ICONS = {
    folder: '<path d="M3.5 7.5A2 2 0 0 1 5.5 5.5h3.2l1.7 1.8h8.1a2 2 0 0 1 2 2V17a2 2 0 0 1-2 2h-13a2 2 0 0 1-2-2v-9.5z"/>',
    file: '<path d="M14 3.5H7.5A1.5 1.5 0 0 0 6 5v14a1.5 1.5 0 0 0 1.5 1.5h9A1.5 1.5 0 0 0 18 19V8.2L14 3.5z"/><path d="M14 3.5V8h4"/>',
    upload: '<path d="M12 16V6"/><path d="M8 9.5 12 5.5l4 4"/><path d="M5 19h14"/>',
    search: '<circle cx="11" cy="11" r="6"/><path d="m16 16 4 4"/>',
    plug: '<path d="M9 7v5"/><path d="M15 7v5"/><path d="M8 12h8v2a4 4 0 0 1-8 0v-2z"/><path d="M12 18v3"/>',
    unplug: '<path d="M8 8 16 16"/><path d="m16 8-8 8"/><path d="M5 19h14"/>',
    grid: '<rect x="4" y="4" width="6" height="6" rx="1"/><rect x="14" y="4" width="6" height="6" rx="1"/><rect x="4" y="14" width="6" height="6" rx="1"/><rect x="14" y="14" width="6" height="6" rx="1"/>',
    list: '<path d="M9 7h11"/><path d="M9 12h11"/><path d="M9 17h11"/><path d="M4 7h.01"/><path d="M4 12h.01"/><path d="M4 17h.01"/>',
    menu: '<path d="M4 7h16"/><path d="M4 12h16"/><path d="M4 17h16"/>',
    down: '<path d="m6 9 6 6 6-6"/>',
    right: '<path d="m9 6 6 6-6 6"/>',
    spin: '<path d="M12 4a8 8 0 1 1-7 4"/>',
    trash: '<path d="M5 7h14"/><path d="M9 7V5h6v2"/><path d="M8 7l1 12h6l1-12"/>'
};

const TEXT_EXTENSIONS = ['txt','md','json','csv','xml','html','htm','css','js','mjs','ts','vue','php','log','yml','yaml','ini','conf','sql','sh','py','env','lock','toml','svg','gitignore','htaccess','scss'];
const IMAGE_EXTENSIONS = ['png','jpg','jpeg','gif','webp','svg','avif'];

function token() {
    return document.querySelector('meta[name="csrf-token"]').content;
}

async function api(url, options = {}) {
    const headers = {
        Accept: 'application/json',
        'X-CSRF-TOKEN': token(),
        ...(options.headers || {}),
    };
    let body = options.body;
    if (body && !(body instanceof FormData)) {
        headers['Content-Type'] = 'application/json';
        body = JSON.stringify(body);
    }
    let response;
    try {
        response = await fetch(url, { ...options, headers, body });
    } catch (error) {
        throw new Error('The browser could not reach the app.');
    }
    if (response.status === 204) return {};
    const text = await response.text();
    let data = {};
    if (text) {
        try { data = JSON.parse(text); } catch (error) { data = { message: 'The FTP request failed.' }; }
    }
    if (!response.ok) throw new Error(data.message || 'The FTP request failed.');
    return data;
}

const TreeNode = {
    name: 'TreeNode',
    props: { node: Object, depth: Number, current: String, selected: String },
    emits: ['toggle', 'open'],
    template: '#tree-node-template',
};

const Icon = {
    props: ['name'],
    computed: {
        markup() { return ICONS[this.name] || ICONS.file; },
    },
    template: '<svg viewBox="0 0 24 24" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" v-html="markup" :class="[\'icon\', name === \'spin\' ? \'spin\' : \'\']"></svg>',
};

Vue.createApp({
    data() {
        return {
            appName: document.querySelector('meta[name="app-name"]').content,
            connected: false,
            configured: false,
            host: '',
            port: null,
            maxUpload: 2 * 1024 * 1024,
            busy: false,
            saving: false,
            gateError: '',
            path: '',
            entries: [],
            query: '',
            view: localStorage.getItem('ftp-view') || 'grid',
            selected: null,
            detailsOpen: false,
            sidebarOpen: false,
            dragging: false,
            dragDepth: 0,
            previewUrl: '',
            dialog: null,
            dialogTitle: '',
            dialogAction: '',
            editorMode: 'edit',
            editorPath: '',
            draftName: '',
            draftContent: '',
            editorBaseline: '',
            toasts: [],
            toastSeq: 0,
            tree: { name: 'Drive', path: '', type: 'directory', open: true, loaded: false, loading: false, children: [] },
        };
    },
    computed: {
        selectedPath() { return this.selected ? this.selected.path : ''; },
        crumbs() {
            const crumbs = [{ name: 'Drive', path: '' }];
            let built = '';
            for (const part of this.path ? this.path.split('/') : []) {
                built = built ? built + '/' + part : part;
                crumbs.push({ name: part, path: built });
            }
            return crumbs;
        },
        visibleEntries() {
            const needle = this.query.trim().toLowerCase();
            if (!needle) return this.entries;
            return this.entries.filter((entry) => entry.name.toLowerCase().includes(needle));
        },
    },
    mounted() {
        this.onKey = (event) => {
            if (event.target.matches('input, textarea')) {
                if (event.key === 'Escape') this.closeDialog();
                return;
            }
            if (event.key === 'Escape') this.closeDialog();
            if (event.key === 'Enter' && this.selected && !this.dialog && !event.target.closest('button, a')) this.openEntry(this.selected);
            if (event.key === 'Delete' && this.selected && !this.dialog && !event.target.closest('button')) this.askDelete();
        };
        window.addEventListener('keydown', this.onKey);
        this.bootstrap();
    },
    beforeUnmount() {
        window.removeEventListener('keydown', this.onKey);
        this.clearPreview();
    },
    methods: {
        async bootstrap() {
            this.busy = true;
            try {
                const status = await api('/ftp/status');
                this.applyStatus(status);
                if (this.connected) await this.loadDirectory('');
            } catch (error) {
                this.gateError = error.message;
            } finally {
                this.busy = false;
            }
        },
        applyStatus(status) {
            this.connected = !!status.connected;
            this.configured = !!status.configured;
            this.host = status.host || '';
            this.port = status.port;
            if (status.maxUpload) this.maxUpload = status.maxUpload;
        },
        async connect() {
            this.busy = true;
            this.gateError = '';
            try {
                const status = await api('/ftp/connect', { method: 'POST', body: {} });
                this.applyStatus(status);
                await this.loadDirectory('');
            } catch (error) {
                this.gateError = error.message;
            } finally {
                this.busy = false;
            }
        },
        async disconnect() {
            this.busy = true;
            try {
                const status = await api('/ftp/disconnect', { method: 'POST', body: {} });
                this.applyStatus(status);
                this.entries = [];
                this.selected = null;
                this.path = '';
                this.query = '';
                this.clearPreview();
                this.tree = { name: 'Drive', path: '', type: 'directory', open: true, loaded: false, loading: false, children: [] };
                this.toast('Disconnected.');
            } catch (error) {
                this.toast(error.message, 'error');
            } finally {
                this.busy = false;
            }
        },
        async openDirectory(path) {
            this.busy = true;
            this.query = '';
            try {
                await this.loadDirectory(path);
                if (window.innerWidth < 900) this.sidebarOpen = false;
            } catch (error) {
                this.toast(error.message, 'error');
            } finally {
                this.busy = false;
            }
        },
        async loadDirectory(path) {
            const data = await api('/ftp/list?path=' + encodeURIComponent(path));
            this.path = data.path || '';
            this.entries = data.entries || [];
            this.syncTree(this.path, this.entries);
            if (this.selected) {
                this.selected = this.entries.find((entry) => entry.path === this.selected.path) || null;
                if (!this.selected) this.clearPreview();
            }
        },
        syncTree(path, entries) {
            const node = this.findNode(path);
            if (!node) return;
            const previous = new Map(node.children.map((child) => [child.path, child]));
            node.children = entries.map((entry) => {
                const existing = previous.get(entry.path);
                if (existing) {
                    existing.name = entry.name;
                    existing.type = entry.type;
                    return existing;
                }
                return { name: entry.name, path: entry.path, type: entry.type, open: false, loaded: false, loading: false, children: [] };
            });
            node.loaded = true;
            node.open = true;
        },
        findNode(path, node = this.tree) {
            if (node.path === path) return node;
            for (const child of node.children) {
                const found = this.findNode(path, child);
                if (found) return found;
            }
            return null;
        },
        async toggleNode(node) {
            if (node.type !== 'directory') return;
            node.open = !node.open;
            if (!node.open || node.loaded) return;
            node.loading = true;
            try {
                const data = await api('/ftp/list?path=' + encodeURIComponent(node.path));
                this.syncTree(node.path, data.entries || []);
            } catch (error) {
                node.open = false;
                this.toast(error.message, 'error');
            } finally {
                node.loading = false;
            }
        },
        async openNode(node) {
            if (node.type === 'file') {
                this.select({ name: node.name, path: node.path, type: 'file', size: null, modified: null });
                return;
            }
            node.open = true;
            await this.openDirectory(node.path);
        },
        select(entry) {
            this.selected = entry;
            if (window.innerWidth > 1100) this.detailsOpen = true;
            this.clearPreview();
            if (entry.type === 'file' && this.isImage(entry) && (entry.size === null || entry.size < 8 * 1024 * 1024)) {
                this.loadPreview(entry);
            }
        },
        async loadPreview(entry) {
            try {
                const response = await fetch('/ftp/download?path=' + encodeURIComponent(entry.path), {
                    headers: { 'X-CSRF-TOKEN': token() },
                });
                if (!response.ok || (this.selected && this.selected.path !== entry.path)) return;
                const blob = await response.blob();
                if (this.selected && this.selected.path === entry.path) this.previewUrl = URL.createObjectURL(blob);
            } catch (error) {
                this.previewUrl = '';
            }
        },
        clearPreview() {
            if (this.previewUrl) URL.revokeObjectURL(this.previewUrl);
            this.previewUrl = '';
        },
        async openEntry(entry) {
            if (!entry) return;
            if (entry.type === 'directory') {
                await this.openDirectory(entry.path);
                return;
            }
            if (this.isText(entry)) {
                await this.edit(entry);
                return;
            }
            await this.download(entry);
        },
        async edit(entry) {
            this.busy = true;
            try {
                const data = await api('/ftp/read?path=' + encodeURIComponent(entry.path));
                this.editorMode = 'edit';
                this.editorPath = entry.path;
                this.draftName = entry.name;
                this.draftContent = data.content;
                this.editorBaseline = data.content;
                this.openDialog('editor', 'Edit ' + entry.name, 'Save');
            } catch (error) {
                this.toast(error.message, 'error');
            } finally {
                this.busy = false;
            }
        },
        startCreateFile() {
            this.editorMode = 'create';
            this.editorPath = '';
            this.draftName = '';
            this.draftContent = '';
            this.editorBaseline = '';
            this.openDialog('editor', 'New file', 'Create');
        },
        askFolder() {
            this.draftName = '';
            this.openDialog('folder', 'New folder', 'Create');
        },
        askRename() {
            if (!this.selected) return;
            this.draftName = this.selected.name;
            this.openDialog('rename', 'Rename', 'Rename');
        },
        askDelete() {
            if (!this.selected) return;
            this.openDialog('delete', 'Delete ' + this.selected.name + '?', 'Delete');
        },
        openDialog(name, title, action) {
            this.dialog = name;
            this.dialogTitle = title;
            this.dialogAction = action;
            this.$nextTick(() => (this.$refs.dialogInput || this.$refs.editorInput)?.focus());
        },
        closeDialog() {
            if (this.dialog === 'editor' && this.draftContent !== this.editorBaseline) {
                if (!window.confirm('Discard unsaved changes?')) return;
            }
            this.dialog = null;
        },
        async submitDialog() {
            this.saving = true;
            try {
                if (this.dialog === 'folder') {
                    await api('/ftp/folder', { method: 'POST', body: { directory: this.path, name: this.draftName } });
                    this.toast('Folder created.');
                } else if (this.dialog === 'rename') {
                    await api('/ftp/rename', { method: 'POST', body: { path: this.selected.path, name: this.draftName } });
                    this.selected = null;
                    this.toast('Renamed.');
                } else if (this.dialog === 'delete') {
                    await api('/ftp/item', { method: 'DELETE', body: { path: this.selected.path, type: this.selected.type } });
                    this.selected = null;
                    this.clearPreview();
                    this.toast('Deleted.');
                } else if (this.dialog === 'editor' && this.editorMode === 'create') {
                    await api('/ftp/file', { method: 'POST', body: { directory: this.path, name: this.draftName, content: this.draftContent } });
                    this.editorBaseline = this.draftContent;
                    this.toast('File created.');
                } else if (this.dialog === 'editor') {
                    await api('/ftp/content', { method: 'PUT', body: { path: this.editorPath, content: this.draftContent } });
                    this.editorBaseline = this.draftContent;
                    this.toast('File saved.');
                }
                this.dialog = null;
                await this.loadDirectory(this.path);
            } catch (error) {
                this.toast(error.message, 'error');
            } finally {
                this.saving = false;
            }
        },
        pickFiles() { this.$refs.fileInput.click(); },
        pickFolder() { this.$refs.folderInput.click(); },
        async onFileInput(event, folder) {
            const files = [...event.target.files];
            event.target.value = '';
            if (!files.length) return;
            await this.uploadList(files.map((file) => ({
                file,
                path: folder ? (file.webkitRelativePath || file.name) : file.name,
            })));
        },
        async uploadList(items) {
            const form = new FormData();
            form.append('directory', this.path);
            items.forEach((item) => {
                form.append('files[]', item.file);
                form.append('paths[]', item.path);
            });
            this.busy = true;
            try {
                const result = await api('/ftp/upload', { method: 'POST', body: form });
                this.toast('Uploaded ' + result.uploaded + (result.uploaded === 1 ? ' file.' : ' files.'));
            } catch (error) {
                this.toast(error.message, 'error');
            } finally {
                try { await this.loadDirectory(this.path); } catch (error) { this.toast(error.message, 'error'); }
                this.busy = false;
            }
        },
        async download(entry) {
            this.busy = true;
            try {
                const response = await fetch('/ftp/download?path=' + encodeURIComponent(entry.path), {
                    headers: { 'X-CSRF-TOKEN': token(), Accept: 'application/octet-stream' },
                });
                if (!response.ok) {
                    let message = 'Download failed.';
                    try { message = (await response.json()).message || message; } catch (error) {}
                    throw new Error(message);
                }
                const blob = await response.blob();
                const url = URL.createObjectURL(blob);
                const link = document.createElement('a');
                link.href = url;
                link.download = entry.name;
                document.body.appendChild(link);
                link.click();
                link.remove();
                URL.revokeObjectURL(url);
            } catch (error) {
                this.toast(error.message, 'error');
            } finally {
                this.busy = false;
            }
        },
        onDragEnter(event) {
            event.preventDefault();
            this.dragDepth += 1;
            this.dragging = true;
        },
        onDragOver(event) {
            event.preventDefault();
            if (event.dataTransfer) event.dataTransfer.dropEffect = 'copy';
        },
        onDragLeave() {
            this.dragDepth = Math.max(0, this.dragDepth - 1);
            this.dragging = this.dragDepth > 0;
        },
        async onDrop(event) {
            event.preventDefault();
            this.dragging = false;
            this.dragDepth = 0;
            const items = await this.collectDrop(event.dataTransfer);
            if (items.length) await this.uploadList(items);
        },
        async collectDrop(dataTransfer) {
            const items = [...(dataTransfer.items || [])];
            const canWalk = items.some((item) => typeof item.webkitGetAsEntry === 'function');
            if (!canWalk) return [...dataTransfer.files].map((file) => ({ file, path: file.name }));
            const collected = [];
            for (const item of items) {
                const entry = item.webkitGetAsEntry ? item.webkitGetAsEntry() : null;
                if (entry) collected.push(...await this.walkEntry(entry, ''));
            }
            return collected;
        },
        async walkEntry(entry, prefix) {
            if (entry.isFile) {
                const file = await new Promise((resolve, reject) => entry.file(resolve, reject));
                return [{ file, path: prefix + file.name }];
            }
            const reader = entry.createReader();
            const children = await this.readAllEntries(reader);
            const files = [];
            for (const child of children) files.push(...await this.walkEntry(child, prefix + entry.name + '/'));
            return files;
        },
        readAllEntries(reader) {
            return new Promise((resolve, reject) => {
                const all = [];
                const read = () => reader.readEntries((batch) => {
                    if (!batch.length) resolve(all);
                    else { all.push(...batch); read(); }
                }, reject);
                read();
            });
        },
        setView(view) {
            this.view = view;
            localStorage.setItem('ftp-view', view);
        },
        extension(name) {
            const clean = String(name || '').toLowerCase();
            const index = clean.lastIndexOf('.');
            return index > 0 ? clean.slice(index + 1) : '';
        },
        isText(entry) {
            const ext = this.extension(entry.name);
            return ext === '' || TEXT_EXTENSIONS.includes(ext);
        },
        isImage(entry) {
            return IMAGE_EXTENSIONS.includes(this.extension(entry.name));
        },
        formatSize(bytes) {
            if (bytes === null || bytes === undefined || bytes === '') return '—';
            const size = Number(bytes);
            if (!Number.isFinite(size)) return '—';
            if (size < 1024) return Math.round(size) + ' B';
            const units = ['KB', 'MB', 'GB', 'TB'];
            let value = size / 1024;
            let index = 0;
            while (value >= 1024 && index < units.length - 1) {
                value /= 1024;
                index += 1;
            }
            const digits = value >= 10 || Math.abs(value - Math.round(value)) < 0.05 ? 0 : 1;
            return value.toFixed(digits) + ' ' + units[index];
        },
        formatDate(unix) {
            if (!unix) return '—';
            return new Date(unix * 1000).toLocaleString();
        },
        toast(message, tone = 'info') {
            const id = ++this.toastSeq;
            this.toasts.push({ id, message, tone });
            setTimeout(() => {
                this.toasts = this.toasts.filter((item) => item.id !== id);
            }, 4200);
        },
    },
}).component('icon', Icon).component('tree-node', TreeNode).mount('#ftp-app');
</script>
</body>
</html>
